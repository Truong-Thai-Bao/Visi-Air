import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/forecaset_service.dart';

class ForecastScreen extends StatefulWidget {
  final String? initialLocation;

  // Nhận location từ ngoài truyền vào, nếu không có thì mặc định là null
  const ForecastScreen({super.key, this.initialLocation});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  // Thay thế bằng class Service thực tế của bạn
  final ForecasetService _forecasetService = ForecasetService();

  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _hourlyForecast = [];
  List<dynamic> _dailyForecast = [];
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Logic xử lý location mặc định là "Hồ Chí Minh"
      String locationToFetch = widget.initialLocation ?? "Hồ Chí Minh";
      if (locationToFetch.isEmpty || locationToFetch.contains("Đang định vị")) {
        locationToFetch = "Hồ Chí Minh";
      }

      // Gọi API từ Service bạn đã viết (Nhớ đổi tên hàm cho khớp với file service của bạn)
      final data = await _forecasetService.fetchForcastData(locationToFetch);

      // Cập nhật giao diện khi có dữ liệu
      setState(() {
        _hourlyForecast = data['today'] ?? [];
        _dailyForecast = data['upcoming'] ?? [];

        // Lấy ngày hiện tại format lại cho phần tiêu đề
        final now = DateTime.now();
        final List<String> months = [
          'Tháng 1',
          'Tháng 2',
          'Tháng 3',
          'Tháng 4',
          'Tháng 5',
          'Tháng 6',
          'Tháng 7',
          'Tháng 8',
          'Tháng 9',
          'Tháng 10',
          'Tháng 11',
          'Tháng 12',
        ];
        _currentDate =
            "${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]}, ${now.year}";

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tải dữ liệu dự báo. Vui lòng thử lại!";
        _isLoading = false;
      });
      debugPrint("Lỗi khi load dự báo: $e");
    }
  }

  // Hàm xác định màu sắc dựa trên chỉ số AQI
  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00E400); // Tốt
    if (aqi <= 100)
      return const Color(
        0xFFD4B300,
      ); // Trung bình (Vàng sậm để dễ đọc chữ trắng)
    if (aqi <= 150) return const Color(0xFFFF7E00); // Kém
    if (aqi <= 200) return const Color(0xFFFF0000); // Xấu
    if (aqi <= 300) return const Color(0xFF8F3F97); // Rất xấu
    return const Color(0xFF7E0023); // Nguy hại
  }

  // Hàm xác định trạng thái dựa trên chỉ số AQI
  String _getAqiStatus(int aqi) {
    if (aqi <= 50) return "Tốt";
    if (aqi <= 100) return "Trung bình";
    if (aqi <= 150) return "Kém";
    if (aqi <= 200) return "Xấu";
    if (aqi <= 300) return "Rất xấu";
    return "Nguy hại";
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: _loadForecastData,
                        child: const Text(
                          "Thử lại",
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- 1. TIÊU ĐỀ ---
                      const Text(
                        "Dự báo chất lượng không khí",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- 2. PHẦN "HÔM NAY" ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Hôm nay",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currentDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Danh sách cuộn ngang (Hourly)
                      if (_hourlyForecast.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _hourlyForecast.asMap().entries.map((
                              entry,
                            ) {
                              int idx = entry.key;
                              var item = entry.value;
                              return _buildHourlyItem(
                                item['time'] ?? "--:--",
                                item['temperature']?.toString() ?? "--",
                                isActive:
                                    idx ==
                                    0, // Mặc định cho item đầu tiên sáng lên
                              );
                            }).toList(),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Không có dữ liệu hôm nay",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // --- 3. PHẦN "DỰ BÁO SẮP TỚI" ---
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dự báo sắp tới",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Danh sách cuộn dọc (Daily)
                      if (_dailyForecast.isNotEmpty)
                        Column(
                          children: _dailyForecast.map((item) {
                            return _buildDailyItem(
                              item['dayOfWeek'] ?? "Unknown",
                              item['date'] ?? "--/--/----",
                              item['temperature']?.toString() ?? "--",
                            );
                          }).toList(),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Không có dữ liệu các ngày tới",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(
    String time,
    String aqiValue, {
    required bool isActive,
  }) {
    int aqi = int.tryParse(aqiValue) ?? 0;
    Color aqiColor = _getAqiColor(aqi);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4A90E2).withOpacity(0.3)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: const Color(0xFF4A90E2))
            : Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: aqiColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.4),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyItem(String day, String date, String aqiValue) {
    int aqi = int.tryParse(aqiValue) ?? 0;
    Color aqiColor = _getAqiColor(aqi);
    String status = _getAqiStatus(aqi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: aqiColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: aqiColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.4),
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
    );
  }
}
