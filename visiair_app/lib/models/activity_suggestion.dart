import 'package:flutter/material.dart';

class ActivitySuggestion {
  final String title;
  final String level;
  final String description;
  final String iconType;

  ActivitySuggestion({
    required this.title,
    required this.level,
    required this.description,
    this.iconType = "", // Khởi tạo giá trị mặc định
  });

  // Hàm factory để map JSON từ Backend thành Object Dart
  factory ActivitySuggestion.fromJson(Map<String, dynamic> json) {
    return ActivitySuggestion(
      title: json['title'] ?? 'Thông tin hoạt động',
      level: json['level'] ?? 'Bình thường',
      description: json['description'] ?? 'Không có mô tả chi tiết.',
      iconType: json['iconType'] ?? '',
    );
  }

  // Trả về Icon tương ứng tuỳ vào từ khoá trong tiêu đề (Title)
  IconData getIconData() {
    // 1. Ưu tiên lấy icon dựa trên trường iconType từ Backend trả về
    switch (iconType.toLowerCase()) {
      case 'run':
        return Icons.directions_run;
      case 'bike':
        return Icons.directions_bike;
      case 'park':
        return Icons.park;
      case 'yoga':
        return Icons.self_improvement;
      case 'home':
        return Icons.home;
      case 'swim':
        return Icons.pool;
    }

    // 2. Dự phòng lấy icon theo từ khoá title nếu backend không trả về iconType
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('thể dục') ||
        lowerTitle.contains('chạy') ||
        lowerTitle.contains('thể thao')) {
      return Icons.directions_run;
    } else if (lowerTitle.contains('khẩu trang')) {
      return Icons.masks;
    } else if (lowerTitle.contains('cửa') || lowerTitle.contains('trong nhà')) {
      return Icons.home;
    }
    return Icons.health_and_safety; // Icon mặc định
  }

  // Trả về màu sắc tương ứng tuỳ vào mức độ (Level)
  Color getStatusColor() {
    final lowerLevel = level.toLowerCase();
    if (lowerLevel.contains('tốt') ||
        lowerLevel.contains('khuyên dùng') ||
        lowerLevel.contains('an toàn')) {
      return Colors.greenAccent;
    } else if (lowerLevel.contains('xấu') ||
        lowerLevel.contains('hạn chế') ||
        lowerLevel.contains('nguy hiểm')) {
      return Colors.redAccent;
    }
    return Colors.orangeAccent; // Mặc định
  }
}
