import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // static const String _baseUrl = 'http://10.0.2.2:3000/api/chat';
  static const String _baseUrl = 'http://127.0.0.1:3005/api/chat';

  final String location;
  ChatService({required this.location});

  Future<String> sendMessage(String message) async {
    try {
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'location': location, 'message': message}),
      );

      if (res.statusCode == 200) {
        return res.body;
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      rethrow;
    }
  }
}
