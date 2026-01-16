// app.js

// 你的 Python 後端 API 基礎網址
const API_BASE_URL = 'http://localhost:8000/api'; // 假設後端在 port 8000

document.getElementById('reservation-form').addEventListener('submit', function(event) {
    event.preventDefault(); // 阻止表單傳統的提交行為

    const date = document.getElementById('date').value;
    const partySize = document.getElementById('party_size').value;
    const resultsDiv = document.getElementById('availability-results');
    
    // 清空舊的結果
    resultsDiv.innerHTML = '正在查詢可用時段...';

    // 呼叫後端 API 來檢查可用性
    fetch(`${API_BASE_URL}/reservations/check-availability?date=${date}&party_size=${partySize}`)
        .then(response => {
            // 檢查 HTTP 狀態碼
            if (!response.ok) {
                // 如果後端返回 4xx 或 5xx 錯誤
                throw new Error(`HTTP 錯誤! 狀態碼: ${response.status}`);
            }
            return response.json(); // 解析 JSON 格式的回應
        })
        .then(data => {
            displayAvailability(data, date, partySize);
        })
        .catch(error => {
            resultsDiv.innerHTML = `❌ 查詢失敗: ${error.message}`;
            console.error('查詢失敗:', error);
        });
});

function displayAvailability(data, date, partySize) {
    const resultsDiv = document.getElementById('availability-results');
    
    // 假設後端回傳的資料結構為: { available_times: ["18:00", "19:30", "20:00"], tables_found: 2 }
    const availableTimes = data.available_times || [];

    if (availableTimes.length === 0) {
        resultsDiv.innerHTML = `
            <h3>📅 ${date} - 🧑 ${partySize} 人</h3>
            <p>很抱歉，此時段**沒有**可供預訂的空位。</p>
        `;
        return;
    }

    // 構建帶有參數的 URL
        const reservationUrl = `customer_details.html?date=${date}&time=${time}&party_size=${partySize}`;

        htmlContent += `
            <a href="${reservationUrl}" style="text-decoration: none;">
                <button 
                    style="background-color: #007bff; font-weight: bold; margin-bottom: 0;"
                >
                    ${time}
                </button>
            </a>
        `;

    availableTimes.forEach(time => {
        // 點擊時，可以跳轉到填寫顧客資料的頁面，並帶入預訂資訊
        htmlContent += `
            <button 
                onclick="alert('您已選擇 ${date} ${time}，將導向填寫顧客資料頁面。')"
                style="background-color: #007bff; font-weight: bold;"
            >
                ${time}
            </button>
        `;
    });

    htmlContent += '</div>';
    resultsDiv.innerHTML = htmlContent;
}