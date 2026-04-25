import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/weather_service.dart';

class AirQualityScreen extends StatefulWidget {
  final String location;
  final Map<String, dynamic>? fullData; // Nhận toàn bộ payload từ Home

  const AirQualityScreen({super.key, required this.location, this.fullData});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  final WeatherService _weatherService = WeatherService();

  bool _isLoading = true;
  String _aqiValue = "--";
  String _status = "Đang tải...";
  Color _aqiColor = Colors.grey;

  // Biến Bụi mịn
  String _pm25Current = "--";
  String _pm25Predict = "--";

  // Lời khuyên và mô tả
  String _description = "Đang lấy thông tin...";
  String _advice = "Vui lòng đợi trong giây lát...";

  // Các biến thời tiết mới cần hiển thị
  String _temperature = "--°C";
  String _humidity = "--%";
  String _dewPoint = "--°C";
  String _pressure = "--°C";
  String _windspeed = "--°C";

  @override
  void initState() {
    super.initState();
    // KIỂM TRA: Nếu có fullData truyền sang thì dùng luôn, không thì gọi API dự phòng
    if (widget.fullData != null) {
      _loadDataFromProps(widget.fullData!);
    } else {
      _fetchAQIDetails();
    }
  }

  // Hàm load dữ liệu trực tiếp từ trang Home
  void _loadDataFromProps(Map<String, dynamic> data) {
    final weatherData = data['weather'] ?? {};
    final aqiData = data['predict'] ?? {};

    setState(() {
      // 1. Lấy dữ liệu AQI
      _aqiValue = aqiData['aqi']?.toString() ?? "--";
      _status = aqiData['status'] ?? "--";

      String colorHex = aqiData['color'] ?? "#808080";
      colorHex = colorHex.replaceAll("#", "");
      if (colorHex.length == 6) colorHex = "FF$colorHex";
      _aqiColor = Color(int.parse(colorHex, radix: 16));

      _pm25Current = aqiData['pm25_current']?.toString() ?? "--";
      _pm25Predict = aqiData['pm25_predict']?.toString() ?? "--";

      // 2. Lấy dữ liệu Thời tiết
      _temperature = weatherData['temperature'] != null
          ? "${weatherData['temperature']} °C"
          : "--°C";
      _humidity = weatherData['humidity'] != null
          ? "${weatherData['humidity']} %"
          : "--%";
      _dewPoint = weatherData['dew'] != null
          ? "${weatherData['dew']} °C"
          : "--°C";

      _pressure = weatherData['pressure'] != null
          ? "${weatherData['pressure']} hPa"
          : "--hPa";

      _windspeed = weatherData['wind_speed'] != null
          ? "${weatherData['wind_speed']} m/s"
          : "--m/s";

      // 3. Lấy trực tiếp Lời khuyên từ Backend
      _description = "Chất lượng không khí hiện tại đang ở mức $_status.";
      _advice = aqiData['advice'] ?? "Hãy theo dõi sức khỏe của bạn.";

      _isLoading = false;
    });
  }

  // Hàm gọi API dự phòng (Phòng trường hợp vào thẳng màn này mà chưa có data từ Home)
  Future<void> _fetchAQIDetails() async {
    setState(() => _isLoading = true);
    try {
      String locationToFetch = widget.location;
      if (locationToFetch.isEmpty || locationToFetch.contains("Đang định vị")) {
        locationToFetch = "Hồ Chí Minh";
      }

      // Gọi lại API fetchCurrentWeather để lấy full payload giống hệt ở Home
      final data = await _weatherService.fetchCurrentWeather(locationToFetch);
      _loadDataFromProps(data); // Tái sử dụng hàm bóc tách dữ liệu ở trên
    } catch (e) {
      debugPrint("Lỗi tải chi tiết AQI: $e");
      setState(() {
        _status = "Lỗi kết nối";
        _description = "Không thể tải dữ liệu từ máy chủ.";
        _advice = "Vui lòng kiểm tra lại kết nối mạng hoặc thử lại sau.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Column(
          children: [
            const SizedBox(height: 15),
            const Text(
              "Chất lượng không khí",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.location,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [SizedBox(width: 48)],
      ),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      // --- 1. VÒNG TRÒN AQI LỚN ---
                      const SizedBox(height: 5),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _aqiColor.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: _aqiColor.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _aqiValue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "AQI",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        style: TextStyle(
                          color: _aqiColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- 2. THẺ MÔ TẢ ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: _aqiColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Mô tả chất lượng",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _description,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 3. THẺ CHI TIẾT THÀNH PHẦN (SHOW AI MODEL) ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Chi tiết Bụi mịn (PM2.5)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            _buildDivider(),
                            _buildComponentRow(
                              "Nồng độ bụi mịn 2.5 trong không khí",
                              "PM2.5",
                              "$_pm25Predict µg/m³",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 4. THẺ THÔNG TIN THỜI TIẾT ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.thermostat_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Thông tin thời tiết chi tiết",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildComponentRow(
                              "Nhiệt độ",
                              "Temperature",
                              _temperature,
                            ),
                            _buildDivider(),
                            _buildComponentRow(
                              "Độ ẩm",
                              "Relative humidity",
                              _humidity,
                            ),
                            _buildDivider(),
                            _buildComponentRow(
                              "Điểm sương",
                              "Dew point",
                              _dewPoint,
                            ),
                            _buildDivider(),
                            _buildComponentRow(
                              "Áp suất",
                              "Pressure",
                              _pressure,
                            ),
                            _buildDivider(),
                            _buildComponentRow(
                              "Tốc độ gió",
                              "Wind speed",
                              _windspeed,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 5. KHUYẾN NGHỊ SỨC KHỎE ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _aqiColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _aqiColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: _aqiColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Khuyến nghị sức khỏe",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _advice,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildComponentRow(String code, String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 20);
  }
}
