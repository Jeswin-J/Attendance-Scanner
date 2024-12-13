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

  static Future<List<Map<String, dynamic>>> fetchAttendance(String date) async {
    final String url = '$baseUrl/$date';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> studentsData = responseData['data'];

        return studentsData.map((student) {
          return {
            'name': student['name'],
            'rollNumber': student['rollNumber'],
            'year': student['year'],
            'department': student['department'],
            'section': student['section'],
            'venue': student['venue'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      throw Exception('Failed to load attendance data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAbsentees(String date) async {
    final response = await http.get(Uri.parse('$baseUrl/absentees/$date'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to fetch absentees');
    }
  }
}
