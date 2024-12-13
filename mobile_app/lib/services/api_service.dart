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

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check-in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        return {
          'success': false,
          'message': 'Network error occurred. Please check your connection.',
          'statusCode': -1,
          'data': null,
        };
      } else if (e is FormatException) {
        return {
          'success': false,
          'message': 'Failed to parse response data.',
          'statusCode': -1,
          'data': null,
        };
      } else {
        return {
          'success': false,
          'message': 'An unexpected error occurred.',
          'statusCode': -1,
          'data': null,
        };
      }
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
        throw Exception('Failed to load attendance data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error occurred. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Failed to parse the response data.');
      } else {
        throw Exception('An unexpected error occurred while fetching attendance data.');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAbsentees(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/absentees/$date'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch absentees. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error occurred. Please check your connection.');
      } else if (e is FormatException) {
        throw Exception('Failed to parse the response data.');
      } else {
        throw Exception('An unexpected error occurred while fetching absentees.');
      }
    }
  }
}
