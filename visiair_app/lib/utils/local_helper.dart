import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // Hàm này làm tất cả: Xin quyền -> Lấy tọa độ -> Dịch ra tên Quận/Huyện
  static Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Kiểm tra GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Việt Nam"; // Lỗi: Chưa bật GPS
    }

    // 2. Kiểm tra & Xin quyền (Hiện cái bảng bạn muốn)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // <-- Bảng hiện ra ở đây
      if (permission == LocationPermission.denied) {
        return "Việt Nam"; // Người dùng từ chối
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return "Việt Nam"; // Từ chối vĩnh viễn
    }

    // 3. Lấy tọa độ và dịch sang tên địa danh
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Lấy Quận/Huyện (subAdministrativeArea) hoặc Thành phố (locality)
        String district = place.subAdministrativeArea ?? "";
        String city = place.administrativeArea ?? "";
        
        // Trả về chuỗi đẹp: "Hóc Môn, Hồ Chí Minh"
        if (district.isNotEmpty && city.isNotEmpty) {
          return "$district, $city";
        }
        return city.isNotEmpty ? city : "Hồ Chí Minh";
      }
    } catch (e) {
      print("Lỗi định vị: $e");
    }
    return "Hồ Chí Minh";
  }
}