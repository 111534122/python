import json
import pymysql
from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# =========================
# MySQL 連線設定
# =========================
def get_db():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="", # XAMPP 預設密碼通常為空
        database="restaurant_booking",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor
    )

# =========================
# 輔助函式：檢查該時段剩餘容量
# =========================
def check_capacity(conn, target_date_time, party_size, exclude_res_id=None):
    cursor = conn.cursor()
    # 1. 取得餐廳總座位數
    cursor.execute("SELECT SUM(capacity) as total_seats FROM restaurant_table")
    total_seats_row = cursor.fetchone()
    total_seats = total_seats_row['total_seats'] if total_seats_row['total_seats'] else 0

    # 2. 定義 2 小時用餐區間 (前後 1 小時 59 分鐘內都算重疊)
    start_time = target_date_time - timedelta(hours=1, minutes=59)
    end_time = target_date_time + timedelta(hours=1, minutes=59)

    # 3. 查詢重疊時段的總預約人數 (不包含已取消的)
    query = """
        SELECT SUM(party_size) as reserved_count 
        FROM reservation 
        WHERE date_time BETWEEN %s AND %s 
        AND status != 'Canceled'
    """
    params = [start_time, end_time]

    # 如果是修改現有訂位，要排除掉原本自己的那一筆
    if exclude_res_id:
        query += " AND id != %s"
        params.append(exclude_res_id)

    cursor.execute(query, tuple(params))
    result = cursor.fetchone()
    reserved_count = result['reserved_count'] if result['reserved_count'] else 0

    # 4. 判斷剩餘容量
    return (reserved_count + party_size) <= total_seats

# =========================
# 1. 新增訂位 (含 2 小時容量控管)
# =========================
@app.route('/reservations', methods=['POST'])
def add_reservation():
    data = request.json
    name = data.get("name")
    phone = data.get("phone")
    party_size = int(data.get("party_size", 2))
    note = data.get("note", "")
    date_time_str = f"{data.get('date')} {data.get('time')}"
    target_date_time = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M')

    conn = get_db()
    cursor = conn.cursor()
    try:
        # 檢查該時段剩餘容量 (間隔 2 小時)
        if not check_capacity(conn, target_date_time, party_size):
            return jsonify({"error": "該時段已客滿，請選擇其他時間或減少人數"}), 400

        # 處理顧客資料
        cursor.execute("SELECT id FROM customer WHERE phone=%s", (phone,))
        customer = cursor.fetchone()
        if customer:
            customer_id = customer["id"]
        else:
            cursor.execute("INSERT INTO customer (name, phone) VALUES (%s, %s)", (name, phone))
            customer_id = conn.insert_id()

        # 寫入預約 (預設 Pending)
        cursor.execute("""
            INSERT INTO reservation (customer_id, party_size, date_time, status, table_ids, note)
            VALUES (%s, %s, %s, 'Pending', '[]', %s)
        """, (customer_id, party_size, date_time_str, note))

        conn.commit()
        return jsonify({"message": "Success"}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# =========================
# 2. 取得所有訂位
# =========================
@app.route('/reservations', methods=['GET'])
def get_reservations():
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT r.id, c.name AS customer_name, c.phone AS phone,
                   r.party_size, r.date_time, r.status, r.table_ids, r.note
            FROM reservation r
            JOIN customer c ON r.customer_id = c.id
            ORDER BY r.date_time DESC
        """)
        rows = cursor.fetchall()
        for r in rows:
            if isinstance(r["date_time"], datetime):
                r["date_time"] = r["date_time"].strftime('%Y-%m-%d %H:%M')
            r["table_ids"] = json.loads(r["table_ids"]) if r["table_ids"] else []
        return jsonify(rows)
    finally:
        cursor.close()
        conn.close()

# =========================
# 3. 修改訂位時間 (含 2 小時容量檢查)
# =========================
@app.route('/reservations/<int:res_id>', methods=['PATCH'])
def update_reservation_time(res_id):
    data = request.json
    new_date_time_str = f"{data.get('date')} {data.get('time')}"
    new_date_time = datetime.strptime(new_date_time_str, '%Y-%m-%d %H:%M')
    
    conn = get_db()
    cursor = conn.cursor()
    try:
        # 先抓取原本的人數
        cursor.execute("SELECT party_size FROM reservation WHERE id = %s", (res_id,))
        res = cursor.fetchone()
        if not res:
            return jsonify({"error": "找不到訂位紀錄"}), 404
        
        # 檢查新時段是否還有足夠容量 (排除自己原本的紀錄)
        if not check_capacity(conn, new_date_time, res['party_size'], exclude_res_id=res_id):
            return jsonify({"error": "修改失敗：新時段已客滿"}), 400

        # 修改時間後，重設狀態為 Pending 並清空 table_ids
        cursor.execute("""
            UPDATE reservation 
            SET date_time = %s, status = 'Pending', table_ids = '[]' 
            WHERE id = %s
        """, (new_date_time_str, res_id))
        
        conn.commit()
        return jsonify({"message": "Time updated and status reset to Pending"}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# =========================
# 4. 取得桌位資訊
# =========================
@app.route('/tables', methods=['GET'])
def get_tables():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM restaurant_table")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(rows)

# =========================
# 5. 手動分配桌位
# =========================
@app.route('/reservations/<int:res_id>/assign', methods=['POST'])
def assign_tables(res_id):
    data = request.json
    table_ids = data.get("table_ids", [])
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            UPDATE reservation SET table_ids=%s, status='Confirmed' WHERE id=%s
        """, (json.dumps(table_ids), res_id))
        conn.commit()
        return jsonify({"message": "Assigned Successfully"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# =========================
# 6. 刪除訂位
# =========================
@app.route('/reservations/<int:res_id>', methods=['DELETE'])
def delete_reservation(res_id):
    conn = get_db()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM reservation WHERE id=%s", (res_id,))
        conn.commit()
        return jsonify({"message": "Deleted"}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)