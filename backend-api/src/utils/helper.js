// Hàm hỗ trợ loại bỏ dấu tiếng Việt
const removeAccents = (str) => {
  if (!str) return '';
  return str.normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd').replace(/Đ/g, 'D');
};

const getWeatherIcon = (code) => {
    // 0: Trời quang đãng (Clear sky)
    if (code === 0) {
        return "sunny"; 
    } 
    // 1, 2: Có mây vài nơi (Mainly clear, partly cloudy)
    else if (code === 1 || code === 2) {
        return "cloudy-day";
    } 
    // 3: Nhiều mây, âm u (Overcast)
    else if (code === 3) {
        return "clouds";
    } 
    // 45, 48: Sương mù (Fog)
    else if (code === 45 || code === 48) {
        return "windy";
    } 
    // 51 -> 67, 80 -> 82: Các loại Mưa (Drizzle, Rain, Showers)
    else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
        return "rainy-day";
    } 
    // 95, 96, 99: Mưa giông sấm sét (Thunderstorm)
    else if (code === 95 || code === 96 || code === 99) {
        // Nếu có tải icon sấm sét thì đổi tên ở đây, chưa có thì dùng tạm mưa
        return "thunderstorm";
    } 
    // Các trường hợp còn lại
    else {
        return "clouds";
    }
};

const getVNDayOfWeek = (dateString) => {
    const days = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    return days[new Date(dateString).getDay()];
};

const formatDateVN = (dateString) => {
    const date = new Date(dateString);
    const d = String(date.getDate()).padStart(2, '0');
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const y = date.getFullYear();
    return `${d}/${m}/${y}`;
};
const getHealthAdvice = (status) => {
    const advices = {
        "Tốt": [
            "Không khí cực kỳ trong lành, rất thích hợp để mở cửa đón gió.",
            "Thời tiết tuyệt vời để bạn thoải mái đi dạo hay tập thể thao ngoài trời.",
            "Bụi mịn ở mức lý tưởng, hãy yên tâm hít thở sâu mà không cần khẩu trang.",
            "Bầu không khí trong trẻo sẽ giúp bạn nạp đầy năng lượng cho ngày mới.",
            "Đừng bỏ lỡ thời điểm tuyệt vời này để ra ngoài tận hưởng khí trời nhé!"
        ],
        "Trung bình": [
            "Không khí ở mức chấp nhận được cho các hoạt động sinh hoạt thường ngày.",
            "Nếu bạn có cơ địa cực kỳ nhạy cảm, hãy lưu ý khi ở ngoài trời quá lâu.",
            "Bạn vẫn có thể tập thể dục, nhưng hãy nghỉ ngơi nếu thấy khó thở.",
            "Nên trang bị một chiếc khẩu trang cơ bản khi di chuyển xa bằng xe máy.",
            "Nhìn chung vẫn an toàn, nhưng hãy tiếp tục theo dõi chỉ số AQI nhé."
        ],
        "Kém": [
            "Không khí bắt đầu ô nhiễm, nhóm người nhạy cảm nên giảm vận động mạnh.",
            "Nhớ đeo khẩu trang cẩn thận trước khi ra đường để tránh hít phải bụi.",
            "Bạn nên ưu tiên tập thể dục trong nhà thay vì chạy bộ ngoài trời hôm nay.",
            "Ô nhiễm nhẹ có thể gây cay mắt, hãy mang thêm kính mát khi lái xe.",
            "Nếu cảm thấy tức ngực hay ho, hãy nhanh chóng tìm nơi có không khí sạch."
        ],
        "Xấu": [
            "Cảnh báo ô nhiễm! Bạn bắt buộc phải đeo khẩu trang chống bụi mịn (N95).",
            "Hãy đóng kín cửa sổ để ngăn bụi và hạn chế tối đa việc ra khỏi nhà.",
            "Không khí đang ở mức xấu, ưu tiên di chuyển bằng ô tô hoặc xe buýt.",
            "Tạm hoãn các hoạt động ngoài trời và nên bật máy lọc không khí trong phòng.",
            "Người có tiền sử bệnh hô hấp, tim mạch tuyệt đối tránh ra ngoài lúc này."
        ],
        "Rất xấu": [
            "Báo động đỏ! Không khí cực kỳ ô nhiễm, chỉ ra ngoài khi thực sự cần thiết.",
            "Việc tập thể dục ngoài trời lúc này rất có hại cho lá phổi của bạn.",
            "Hãy đóng chặt cửa nẻo và bật máy lọc không khí ở công suất cao nhất.",
            "Trẻ nhỏ và người lớn tuổi cần được bảo vệ tuyệt đối trong môi trường kín.",
            "Bắt buộc dùng khẩu trang N95 và kính bảo hộ nếu phải đi ra đường."
        ],
        "Nguy hại": [
            "Mức độ nguy hiểm tột độ, đe dọa trực tiếp đến sức khỏe của tất cả mọi người!",
            "Tuyệt đối ở yên trong nhà, dán kín các khe hở để tránh không khí độc lọt vào.",
            "Bật máy lọc không khí liên tục và tránh mọi hoạt động khiến bạn thở gấp.",
            "Mọi nỗ lực ra ngoài lúc này đều có thể gây tổn thương màng phổi nghiêm trọng.",
            "Ngay cả người khỏe mạnh cũng sẽ gặp nguy hiểm tức thì nếu đi ra ngoài."
        ]
    };

    const options = advices[status] || ["Dữ liệu đang được cập nhật. Hãy chú ý bảo vệ sức khỏe nhé."];
    
    // Chọn ngẫu nhiên 1 câu trong 5 câu để trả về
    return options[Math.floor(Math.random() * options.length)];
};

module.exports = {removeAccents,getWeatherIcon,getVNDayOfWeek,formatDateVN,getHealthAdvice}