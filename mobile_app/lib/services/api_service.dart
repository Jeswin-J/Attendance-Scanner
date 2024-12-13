import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.29.111:8080';

  // Method to send the POST request and return the response
  static Future<Map<String, dynamic>?> checkIn(String rollNumber) async {
    final url = Uri.parse('$baseUrl/checkIn');

    // Request body
    final Map<String, String> requestBody = {
      'rollNumber': rollNumber,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Failed to check-in: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during POST request: $e');
    }
    return null;
  }
}
