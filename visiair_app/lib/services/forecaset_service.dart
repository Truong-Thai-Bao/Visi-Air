import 'dart:convert';
import 'package:http/http.dart' as http;

class ForecasetService {
  Future<Map<String, dynamic>> fetchForcastData(String name) async {
    try {
      // Giả sử API nhận body JSON chứa địa điểm
      final res = await http.post(
        Uri.parse('http://127.0.0.1:3005/api/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );
      print(res.body);
      if (res.statusCode == 200) {
        final decodedJson = jsonDecode(res.body);
        print(decodedJson);
        return decodedJson['data'];
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
