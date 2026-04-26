import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityService {
  Future<Map<String, dynamic>> activitySuggest(String location, int aqi) async {
    try {
      // Giả sử API nhận body JSON chứa địa điểm
      final res = await http.post(
        Uri.parse('https://visi-air.onrender.com/api/activitySuggestion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'location': location, 'aqi': aqi}),
      );
      print('Response body: ${res.body}');
      if (res.statusCode == 200) {
        final decodedJson = jsonDecode(res.body);
        print('Decoded response: $decodedJson');
        return decodedJson as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load activity suggestions. Status: ${res.statusCode}',
        );
      }
    } catch (e) {
      print('Error in activitySuggest: $e');
      rethrow;
    }
  }
}
