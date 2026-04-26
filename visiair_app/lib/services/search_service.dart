import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  Future<List<dynamic>> searchAQI(String name) async {
    try {
      final String baseUrl = 'https://visi-air.onrender.com/api/search';
      final String url = name.isEmpty
          ? baseUrl
          : '$baseUrl/${Uri.encodeComponent(name)}';

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final decodedJson = jsonDecode(res.body);
        print(decodedJson);
        return decodedJson['data'] as List<dynamic>;
      } else {
        throw Exception(
          'Lỗi API: Mã ${res.statusCode} - Không thể tải dữ liệu',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> currentAQI(String name) async {
    try {
      final String baseUrl = 'https://visi-air.onrender.com/api/search';
      final String url = name.isEmpty
          ? baseUrl
          : '$baseUrl/${Uri.encodeComponent(name)}';

      final res = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final decodedJson = jsonDecode(res.body);
        print(decodedJson);
        return decodedJson['data'];
      } else {
        throw Exception(
          'Lỗi API: Mã ${res.statusCode} - Không thể tải dữ liệu',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
