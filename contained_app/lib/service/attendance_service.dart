import 'package:contained_app/utils/database_helper.dart';

class AttendanceService {
  static Future<void> markStudentAttendance(String rollNumber, String batch, String venue) async {
    try {
      await DatabaseHelper.markAttendance(rollNumber, batch, venue);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
