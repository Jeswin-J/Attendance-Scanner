import 'package:contained_app/utils/database_helper.dart';

class AttendanceService {
  static Future<void> markStudentAttendance(String rollNumber) async {
    try {
      await DatabaseHelper.markAttendance(rollNumber);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
