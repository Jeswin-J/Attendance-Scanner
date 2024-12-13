import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.29.111:8080';

  static Future<Map<String, dynamic>> checkIn(String rollNumber) async {
    final url = Uri.parse('$baseUrl/checkIn');

    final Map<String, String> requestBody = {
      'rollNumber': rollNumber,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      return json.decode(response.body);
    } catch (e) {
      print('Error during POST request: $e');
      return {
        'success': false,
        'message': 'Error occurred during request.',
        'statusCode': -1,
        'data': null,
      };
    }
  }
}
