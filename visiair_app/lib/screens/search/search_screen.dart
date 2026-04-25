import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _cities = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0; // Để làm hiệu ứng chọn (sáng viền)

  @override
  void initState() {
    super.initState();
    // Vừa vào trang là gọi API với chuỗi rỗng để lấy 5 thành phố mặc định
    _fetchCities("");
  }

  // Hàm gọi API
  Future<void> _fetchCities(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _searchService.searchAQI(query);
      setState(() {
        _cities = (data as List<dynamic>?) ?? [];
        _selectedIndex = 0; // Reset lựa chọn về item đầu tiên
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tìm thấy dữ liệu. Vui lòng thử lại!";
        _isLoading = false;
        _cities = [];
      });
      debugPrint("Lỗi SearchScreen: $e"); // In ra log để dễ dàng debug
    }
  }

  // Hàm chuyển đổi mã màu Hex từ backend thành Color của Flutter
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Thêm độ đục (opacity) 100%
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- 1. TIÊU ĐỀ ---
              const Text(
                "Chọn địa điểm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Tìm kiếm thành phố bạn quan tâm để cập nhật dự báo chất lượng không khí chi tiết nhất.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              const SizedBox(height: 15),

              // --- 2. THANH TÌM KIẾM ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Tìm kiếm thành phố...",
                            hintStyle: TextStyle(color: Colors.white38),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            _fetchCities(
                              value.trim(),
                            ); // Bấm Enter trên bàn phím sẽ gọi API
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nút vị trí
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _fetchCities(
                            "",
                          ); // Bấm nút này sẽ reset về 5 thành phố gốc
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. LƯỚI THÀNH PHỐ (GRID VIEW) ---
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : _cities.isEmpty
                    ? const Center(
                        child: Text(
                          "Không tìm thấy kết quả",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.92, // Đã chỉnh lại một chút cho thẻ cân đối
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _cities.length,
                        itemBuilder: (context, index) {
                          final city = _cities[index];
                          final isSelected = index == _selectedIndex;

                          // Lấy dữ liệu an toàn
                          final cityName = city['name'] ?? "Unknown";
                          final aqiValue = city['aqi']?.toString() ?? "--";
                          final status = city['status'] ?? "--";
                          final colorHex = city['color'];
                          final advice = city['advice'] ?? "";

                          // Parse màu động từ API 1 lần để dùng chung
                          final dynamicColor = _parseColor(colorHex);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                18,
                              ), // Trừ hao viền để thoáng hơn
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4A90E2).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF4A90E2),
                                        width: 1.5,
                                      )
                                    : Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- HEADER: Chữ "Chỉ số AQI" & Vòng tròn ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          "Chỉ số AQI",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: dynamicColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: dynamicColor.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          aqiValue,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // --- BODY: Lời khuyên nằm ở giữa ---
                                  // --- BODY: Lời khuyên nằm ở giữa ---
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .centerLeft, // Căn giữa chữ theo chiều dọc
                                      child: Text(
                                        advice,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // --- FOOTER: Trạng thái và Tên thành phố ---
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color:
                                          dynamicColor, // Điểm nhấn: Trùng màu với AQI!
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cityName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
