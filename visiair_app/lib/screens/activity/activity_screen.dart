import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/activity_suggestion.dart'; // Import Model
import '../../services/activity_service.dart';  // Import Service

class ActivityScreen extends StatefulWidget {
  final String location;
  const ActivityScreen({super.key, required this.location});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ActivityService _activityService = ActivityService();
  
  // Biến chứa dữ liệu tương lai
  late Future<List<ActivitySuggestion>> _activityFuture;

  // Giả sử lấy từ API location hoặc truyền từ màn hình trước
  int currentAQI = 32; // Ví dụ AQI hiện tại

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy dữ liệu ngay khi màn hình khởi tạo
    _activityFuture = _activityService.fetchActivities(currentAQI,widget.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Lời khuyên sức khỏe",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 2),
                Flexible(child: Text(
                  widget.location,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Biến động
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                )
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Nút refresh để thử tải lại dữ liệu
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // Giả lập đổi AQI để thấy dữ liệu thay đổi
                currentAQI = currentAQI == 32 ? 160 : 32; 
                _activityFuture = _activityService.fetchActivities(currentAQI,widget.location);
              });
            },
          )
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
          // Dùng FutureBuilder để xử lý dữ liệu bất đồng bộ (Async)
          child: FutureBuilder<List<ActivitySuggestion>>(
            future: _activityFuture,
            builder: (context, snapshot) {
              // 1. Đang tải dữ liệu -> Hiện vòng xoay
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              
              // 2. Có lỗi -> Hiện thông báo lỗi
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
              }

              // 3. Có dữ liệu -> Hiển thị danh sách
              final activities = snapshot.data ?? [];

              if (activities.isEmpty) {
                return const Center(child: Text("Không có lời khuyên nào.", style: TextStyle(color: Colors.white)));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final item = activities[index];
                  return _buildAdviceCard(item); // Truyền object Model vào
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget nhận vào Model thay vì String rời rạc
  Widget _buildAdviceCard(ActivitySuggestion item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            // Dùng hàm trong Model để lấy Icon
            child: Icon(item.getIconData(), color: Colors.white, size: 28),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Hiển thị nhãn đánh giá (Tốt/Xấu)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        item.level,
                        style: TextStyle(color: item.getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}