import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../search/search_screen.dart'; // [MỚI] Import trang tìm kiếm
import '../forecast/forecast_screen.dart';
import '../home/air_quality_screen.dart'; // Import trang chất lượng không khí'
import '../activity/activity_screen.dart';
import '../chat/chat_screen.dart';
import '../../utils/local_helper.dart';
import '../../services/weather_service.dart';
import '../../screens/settings/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String _location = "Đang định vị..."; // Giá trị mặc định ban đầu
  int _currentAqi = 0; // Biến lưu trữ AQI để truyền sang ActivityScreen

  @override
  void initState() {
    super.initState();
    _initLocation(); // Gọi hàm lấy vị trí ngay khi mở màn hình
  }

  Future<void> _initLocation() async {
    String finalLocation = "Hồ Chí Minh"; // Vị trí mặc định nếu không lấy được

    try {
      // Hàm này sẽ tự động kích hoạt bảng xin quyền -> Đợi người dùng bấm -> Lấy tên
      String locationName = await LocationHelper.getCurrentLocation();

      // Kiểm tra nếu có dữ liệu hợp lệ (không rỗng và không chứa chữ "lỗi")
      if (locationName.isNotEmpty &&
          !locationName.toLowerCase().contains("lỗi")) {
        finalLocation = locationName;
      }
    } catch (e) {
      print("Lỗi lấy vị trí: $e -> Chuyển sang mặc định: Hồ Chí Minh");
    }

    if (mounted) {
      setState(() {
        _location = finalLocation;
      });
    }
  }

  // Hàm cập nhật AQI từ HomeContent để dùng cho ActivityScreen
  void _updateAqi(int aqi) {
    if (_currentAqi != aqi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          setState(() {
            _currentAqi = aqi;
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình tương ứng với từng tab
    final List<Widget> _pages = [
      HomeContent(
        location: _location,
        onAqiUpdated: _updateAqi,
      ), // Tab 0: Trang chủ
      const SearchScreen(), // Tab 1: Trang tìm kiếm
      const ForecastScreen(), // Tab 2: Trang dự báo
      ActivityScreen(
        location: _location,
        aqi: _currentAqi,
      ), // Tab 3: Trang hoạt động
      const NotificationScreen(), // Tab 4
    ];
    return Scaffold(
      extendBody: true,
      // Hiển thị màn hình theo tab đang chọn
      body: _pages[_selectedIndex],
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(location: _location),
              ),
            );
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/login_logo.jpg',
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Widget Thanh Menu Dưới Cùng ---
  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2648),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_filled, 0),
          _navItem(Icons.search, 1),
          _navItem(Icons.air, 2),
          _navItem(Icons.health_and_safety_outlined, 3),
          _navItem(Icons.settings, 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? Colors.white : Colors.white38,
      ),
    );
  }
}

// ===============================================================
// NỘI DUNG TRANG CHỦ
// ===============================================================
class HomeContent extends StatefulWidget {
  final String location;
  final Function(int)? onAqiUpdated;
  const HomeContent({super.key, required this.location, this.onAqiUpdated});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _fullData;
  String _temperature = "--°";
  String _windSpeed = "-- km/h";
  String _humidity = "--%";
  String _time = "Đang cập nhật...";
  String _currentIconName = "clouds";

  // --- [SỬA LỖI] KHAI BÁO THÊM 3 BIẾN AQI BỊ THIẾU Ở ĐÂY ---
  String _aqiValue = "--";
  String _aqiStatus = "--";
  Color _aqiColor = const Color(0xFF4CAF50); // Mặc định là xanh lá

  List<dynamic> _forecastList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.location != "Đang định vị...") {
      _loadWeatherData();
    }
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location &&
        widget.location != "Đang định vị...") {
      _loadWeatherData();
    }
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);
    try {
      String locationToFetch = widget.location;
      if (locationToFetch.isEmpty || locationToFetch.contains("Đang định vị")) {
        locationToFetch = "Hồ Chí Minh";
      }

      // Gọi 1 API duy nhất lấy được cả weather và predict!
      final data = await _weatherService.fetchCurrentWeather(locationToFetch);

      setState(() {
        // Tách 2 cục dữ liệu ra từ JSON
        final weatherData = data['weather'];
        final aqiData = data['predict'];

        // Lưu lại TOÀN BỘ dữ liệu để lát truyền sang trang chi tiết
        _fullData = data;

        // --- XỬ LÝ THỜI TIẾT ---
        if (weatherData != null) {
          final temp = weatherData['temperature'];
          final humid = weatherData['humidity'];
          final wind = weatherData['wind_speed'];
          final rawTime = weatherData['time'];
          final forecast = weatherData['forecast'];
          final String fetchedIcon =
              weatherData['icon']?.toString() ?? "clouds";

          _temperature = temp != null ? "$temp℃" : "--℃";
          _humidity = humid != null ? "$humid%" : "--%";
          _windSpeed = wind != null ? "$wind m/s" : "-- m/s";

          if (rawTime != null) {
            try {
              DateTime parsedTime = DateTime.parse(rawTime.toString());
              _time =
                  "Cập nhật lúc: ${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')} - ${parsedTime.day}/${parsedTime.month}/${parsedTime.year}";
            } catch (_) {
              _time = rawTime.toString().replaceAll('T', ' ');
            }
          }
          _forecastList = forecast != null ? List<dynamic>.from(forecast) : [];
          _currentIconName = fetchedIcon;
        }

        // --- XỬ LÝ AQI CHO THẺ HIỂN THỊ TẠI HOME ---
        if (aqiData != null) {
          _aqiValue = aqiData['aqi']?.toString() ?? "--";
          _aqiStatus = aqiData['status'] ?? "--";

          String colorHex = aqiData['color'] ?? "#4CAF50";
          colorHex = colorHex.replaceAll("#", "");
          if (colorHex.length == 6) colorHex = "FF$colorHex";
          _aqiColor = Color(int.parse(colorHex, radix: 16));

          // Đẩy dữ liệu AQI ngược lên HomeScreen
          if (widget.onAqiUpdated != null && aqiData['aqi'] != null) {
            int parsedAqi = int.tryParse(aqiData['aqi'].toString()) ?? 0;
            widget.onAqiUpdated!(parsedAqi);
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi lấy dữ liệu: $e");
      setState(() {
        _time = "Không thể tải dữ liệu";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
        child: Column(
          children: [
            Text(
              widget.location,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _time,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // 3. HIỂN THỊ ẢNH 3D LỚN Ở TRANG CHỦ
            Image.asset(
              'assets/icons/weather/$_currentIconName.png',
              width: 120, // To ra một chút cho đẹp
              height: 120,
              fit: BoxFit.contain,
              // Xử lý lỗi nếu ảnh không tồn tại
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.cloud, size: 100, color: Colors.white),
            ),

            const SizedBox(height: 10),
            const Text(
              "Thời tiết hiện tại",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem("Nhiệt độ", _temperature),
                      _buildStatItem("Tốc độ gió", _windSpeed),
                      _buildStatItem("Độ ẩm", _humidity),
                    ],
                  ),
            const SizedBox(height: 20),

            // Thẻ AQI
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AirQualityScreen(
                      location: widget.location,
                      fullData: _fullData,
                    ), // Truyền toàn bộ data
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _aqiColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _aqiValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AQI $_aqiValue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _aqiStatus,
                            style: TextStyle(
                              color: _aqiColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Chạm để xem chi tiết",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Dự báo nhiệt độ",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            const SizedBox(height: 18),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _forecastList.isNotEmpty
                    ? _forecastList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        String timeStr = item['time']?.toString() ?? "--:--";
                        String tempStr = item['temperature'] != null
                            ? "${item['temperature']}°"
                            : "--°";

                        // 4. LẤY TÊN ICON CHO TỪNG KHUNG GIỜ
                        String hourlyIconName =
                            item['icon']?.toString() ?? "clouds";

                        return _buildHourlyItem(
                          timeStr,
                          tempStr,
                          hourlyIconName, // Truyền biến String thay vì IconData
                          isActive: index == 0,
                        );
                      }).toList()
                    : [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Chưa có dữ liệu dự báo",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 5. CẬP NHẬT HÀM NÀY NHẬN VÀO MỘT STRING
  Widget _buildHourlyItem(
    String time,
    String temp,
    String iconName, { // Sửa IconData icon -> String iconName
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4A90E2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // HIỂN THỊ ICON 3D NHỎ CHO TỪNG GIỜ
          Image.asset(
            'assets/icons/weather/$iconName.png',
            width: 35,
            height: 35,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud, color: Colors.white, size: 28),
          ),

          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
