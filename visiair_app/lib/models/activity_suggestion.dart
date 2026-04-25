import 'package:flutter/material.dart';

class ActivitySuggestion {
  final String id;
  final String title;
  final String description;
  final String iconType; // Ví dụ: 'run', 'yoga', 'mask'
  final String level;    // Ví dụ: 'Tốt', 'Cẩn thận'

  ActivitySuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.iconType,
    required this.level,
  });

  // Hàm tiện ích: Chuyển tên icon từ API thành IconData của Flutter
  IconData getIconData() {
    switch (iconType) {
      case 'run': return Icons.directions_run;
      case 'bike': return Icons.directions_bike;
      case 'yoga': return Icons.self_improvement;
      case 'park': return Icons.park;
      case 'swim': return Icons.pool;
      case 'mask': return Icons.masks; // Khuyên đeo khẩu trang
      case 'home': return Icons.home;  // Khuyên ở nhà
      default: return Icons.help_outline;
    }
  }

  // Hàm tiện ích: Màu sắc dựa trên mức độ khuyến nghị
  Color getStatusColor() {
    switch (level) {
      case 'Tốt': return Colors.greenAccent;
      case 'Vừa phải': return Colors.orangeAccent;
      case 'Xấu': return Colors.redAccent;
      default: return Colors.white;
    }
  }
}