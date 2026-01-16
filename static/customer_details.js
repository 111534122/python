// customer_details.js

const API_BASE_URL = 'http://localhost:8000/api'; // 後端 API 網址

let reservationData = {}; // 儲存從 URL 獲取的訂位數據

// 1. 從 URL 參數獲取訂位數據
function getReservationParams() {
    const params = new URLSearchParams(window.location.search);
    reservationData = {
        date: params.get('date'),
        time: params.get('time'),
        party_size: parseInt(params.get('party_size'))
    };
    
    // 檢查是否有遺失的參數，若有則導回首頁
    if (!reservationData.date || !reservationData.time || isNaN(reservationData.party_size)) {
        alert("訂位資訊不完整，請重新選擇時段。");
        window.location.href = 'index.html';
        return false;
    }
    return true;
}

// 2. 顯示訂位摘要
function displaySummary() {
    document.getElementById('summary-date').textContent = reservationData.date;
    document.getElementById('summary-time').textContent = reservationData.time;
    document.getElementById('summary-party-size').textContent = reservationData.party_size;
}

// 3. 處理表單提交
document.getElementById('details-form').addEventListener('submit', function(event) {
    event.preventDefault();

    const messageArea = document.getElementById('message-area');
    messageArea.textContent = '處理中，請稍候...';
    messageArea.style.color = 'blue';

    // 收集顧客輸入的數據
    const customerData = {
        name: document.getElementById('name').value,
        phone: document.getElementById('phone').value,
        email: document.getElementById('email').value,
        notes: document.getElementById('notes').value
    };

    // 合併所有數據為一個 POST 請求的 Payload
    const payload = {
        ...reservationData,
        ...customerData
    };
    
    // 發送 POST 請求到後端 API
    fetch(`${API_BASE_URL}/reservations/create`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload)
    })
    .then(response => response.json().then(data => ({ status: response.status, body: data })))
    .then(({ status, body }) => {
        if (status === 201 && body.success) {
            // 訂位成功
            messageArea.textContent = `✅ 訂位成功！您的訂位編號是：${body.reservation_id}。`;
            messageArea.style.color = 'green';
            document.getElementById('details-form').reset(); // 清空表單
            // 可以導向一個訂位成功頁面
        } else {
            // 訂位失敗
            messageArea.textContent = `❌ 訂位失敗: ${body.message || '伺服器錯誤'}`;
            messageArea.style.color = 'red';
        }
    })
    .catch(error => {
        messageArea.textContent = `❌ 連線失敗或網路錯誤: ${error.message}`;
        messageArea.style.color = 'red';
        console.error('創建訂位時出錯:', error);
    });
});

// 頁面載入時執行
if (getReservationParams()) {
    displaySummary();
}