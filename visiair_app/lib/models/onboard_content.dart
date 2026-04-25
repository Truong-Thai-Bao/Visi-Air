
class OnboardingContent {
  final String image;
  final String title;
  final String description;
  final String engSub;


  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
    required this.engSub,
  });
}

// Đây là danh sách dữ liệu giả lập cho 3 trang
// Bạn thay tên ảnh và nội dung text cho phù hợp nhé
 List<OnboardingContent> contents = [
  // Trang 1: Bảo vệ
  OnboardingContent(
    image: 'assets/images/shield.png', 
    title: "Lá chắn không khí cho bạn",
    description: "Giám sát chất lượng không khí theo thời gian thực để bảo vệ sức khỏe hô hấp của bạn và gia đình.",
    engSub: "Protection for your lungs",
  ),
  // Trang 2: Công nghệ AI (Điểm mạnh của đồ án)
  OnboardingContent(
    image: 'assets/images/ai_tech.png',
    title: "Dự báo chuẩn xác bằng AI",
    description: "Công nghệ Deep Learning tiên tiến giúp dự báo chính xác xu hướng ô nhiễm trong 24 giờ tới.",
    engSub: "Advanced AI Technology",
  ),
  // Trang 3: Chatbot & Sức khỏe
  OnboardingContent(
    image: 'assets/images/login_logo.jpg',
    title: "Trợ lý sức khỏe 24/7",
    description: "Trò chuyện cùng AI để nhận lời khuyên y tế và gợi ý hoạt động phù hợp với thể trạng của bạn.",
    engSub: "Personalized Health Advice",
  ),
  // Trang 4: Phong cách sống (Chốt đơn)
  OnboardingContent(
    image: 'assets/images/walk.png',
    title: "Sống khỏe, Sống chủ động",
    description: "Đừng để ô nhiễm cản bước chân bạn. Lên kế hoạch cho ngày mới hoàn hảo cùng AirVibe.",
    engSub: "Live active, Live safe",
  ),
];