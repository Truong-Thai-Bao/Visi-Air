import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Trạng thái của các nút gạt (Switch)
  bool _masterSwitch = true;
  bool _morningAlert = true;
  bool _weatherAlert = true;
  bool _airQualityAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Cài đặt Thông báo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundGradientStart, Color.fromARGB(255, 1, 24, 59)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- 1. TRẠNG THÁI HỆ THỐNG ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, // Nền trắng như thiết kế
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Trạng thái Thông báo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),
                      _buildStatusRow("Hệ thống", "Cho phép", Colors.green),
                      _buildStatusRow("Thông báo chờ", "1", Colors.blue),
                      _buildStatusRow("Kiểm tra cuối", "0 phút trước", Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 2. CÀI ĐẶT CHÍNH ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cài đặt Chính", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.black54),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Bật Thông báo", style: TextStyle(fontWeight: FontWeight.w600)),
                                Text("Bật/tắt tất cả thông báo từ ứng dụng", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _masterSwitch,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (val) => setState(() => _masterSwitch = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 3. LOẠI THÔNG BÁO ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Loại Thông báo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      _buildSwitchItem(Icons.wb_sunny, "Chào buổi sáng", "Thông báo chào buổi sáng lúc 7h hàng ngày", Colors.orange, _morningAlert, (val) => setState(() => _morningAlert = val)),
                      const Divider(height: 30),
                      _buildSwitchItem(Icons.cloud, "Cảnh báo Thời tiết", "Thông báo khi thời tiết khó chịu (nắng nóng, mưa...)", Colors.blue, _weatherAlert, (val) => setState(() => _weatherAlert = val)),
                      const Divider(height: 30),
                      _buildSwitchItem(Icons.air, "Cảnh báo Chất lượng không khí", "Thông báo khi chất lượng không khí kém", Colors.green, _airQualityAlert, (val) => setState(() => _airQualityAlert = val)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, String subtitle, Color iconColor, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}