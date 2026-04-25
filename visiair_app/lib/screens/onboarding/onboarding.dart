import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/onboard_content.dart'; // Import file model vừa tạo
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0; // Biến theo dõi mình đang ở trang số mấy
  late PageController _controller; // Biến điều khiển lật trang

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); // Hủy biến điều khiển khi thoát màn hình để nhẹ máy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- LỚP 1: NỀN GRADIENT ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundGradientStart,
                  Color.fromARGB(255, 1, 24, 59),
                ],
              ),
            ),
          ),

          // --- LỚP 2: PAGE VIEW (Nội dung trượt) ---
          PageView.builder(
            controller: _controller,
            itemCount: contents.length, // Số lượng trang lấy từ file model
            onPageChanged: (int index) {
              setState(() {
                _currentIndex =
                    index; // Cập nhật lại số trang khi người dùng vuốt tay
              });
            },
            itemBuilder: (_, i) {
              // Đây là hàm vẽ giao diện cho TỪNG TRANG
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center, // Căn giữa ảnh và vòng tròn
                      children: [
                        // Lớp 1: Vòng tròn mờ phát sáng (nằm dưới)
                        Container(
                          width: 220, // Độ rộng vòng tròn
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Màu nền tròn mờ bên trong (Trắng đục 10%)
                            color: Colors.white.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                  0.15,
                                ), // Màu tỏa sáng (Trắng 15%)
                                blurRadius: 60, // Độ nhòe (Càng lớn càng ảo)
                                spreadRadius: 10, // Độ lan rộng ra xung quanh
                              ),
                              // Thêm một lớp bóng nữa cho có chiều sâu (tùy chọn)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 100,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 200, // Độ rộng vòng tròn
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Màu nền tròn mờ bên trong (Trắng đục 10%)
                            color: Colors.white.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                  0.15,
                                ), // Màu tỏa sáng (Trắng 15%)
                                blurRadius: 60, // Độ nhòe (Càng lớn càng ảo)
                                spreadRadius: 10, // Độ lan rộng ra xung quanh
                              ),
                              // Thêm một lớp bóng nữa cho có chiều sâu (tùy chọn)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 100,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        // Lớp 2: Hình ảnh nhân vật (nằm đè lên trên)
                        Image.asset(
                          contents[i].image,
                          height:
                              240, // Chỉnh ảnh nhỏ hơn vòng tròn một chút (240 < 260)
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    // Tiêu đề
                    Text(
                      contents[i].title, // Lấy tiêu đề theo trang thứ i
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        height: 3,
                      ),
                    ),

                    // Mô tả
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        contents[i].description, // Lấy mô tả theo trang thứ i
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        contents[i].engSub,
                        textAlign:
                            TextAlign.center, // Lấy mô tả theo trang thứ i]
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- LỚP 3: CÁC THÀNH PHẦN CỐ ĐỊNH (Tagline, Dots, Button) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const Spacer(), // Đẩy mọi thứ xuống đáy
                // Tagline cố định
                const SizedBox(height: 40),
                // Dấu chấm (Dots Indicator) - Tự động đổi màu theo _currentIndex
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => _buildDot(index), // Gọi hàm vẽ chấm
                  ),
                ),

                const SizedBox(height: 20),

                // Nút Tiếp tục / Bắt đầu
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // LOGIC QUAN TRỌNG:
                        if (_currentIndex == contents.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        } else {
                          // Nếu chưa phải trang cuối -> Lật sang trang kế tiếp
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.pressed))
                              return AppColors.primaryBlue;
                            return Colors.white;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.pressed))
                              return Colors.white;
                            return AppColors.primaryBlue;
                          },
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 8,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      // Đổi chữ "Tiếp tục" thành "Bắt đầu" nếu ở trang cuối
                      child: Text(
                        _currentIndex == contents.length - 1
                            ? "Bắt đầu"
                            : "Tiếp tục",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // --- LỚP 4: NÚT BỎ QUA ---
          // Ẩn nút bỏ qua nếu đang ở trang cuối cùng
          if (_currentIndex != contents.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () {
                  // Nhảy thẳng đến trang cuối cùng
                  _controller.jumpToPage(contents.length - 1);
                },
                child: const Text(
                  "Bỏ qua",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HÀM VẼ DẤU CHẤM ---
  // Tách ra cho code gọn gàng, logic thông minh hơn
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Hiệu ứng co giãn mượt mà
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: _currentIndex == index
          ? 30
          : 6, // Nếu là trang hiện tại thì dài ra
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
