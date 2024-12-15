import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  // Initialize the database
  static Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'auditorium_attendance.db');

    if (await databaseExists(path)) {
      _database = await openDatabase(path);
    } else {
      await _copyDatabaseFromAssets(path);
      _database = await openDatabase(path);
    }

    return _database!;
  }

  static Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      final ByteData data = await rootBundle.load('assets/auditorium_attendance.db');
      final List<int> bytes = data.buffer.asUint8List();

      await File(path).writeAsBytes(bytes);
    } catch (e) {
      throw Exception("Failed to copy database: $e");
    }
  }

  // Fetch student by roll number
  static Future<Map<String, dynamic>?> getStudentByRollNumber(String rollNumber) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'student',
      where: 'roll_number = ?',
      whereArgs: [rollNumber],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // No student found
  }

  // Fetch attendance for a specific date
  static Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    final db = await _getDatabase();
    return await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // Mark attendance for a student
  static Future<void> markAttendance(String rollNumber) async {
    final student = await getStudentByRollNumber(rollNumber);

    if (student != null) {
      // If student exists, insert attendance record
      final db = await _getDatabase();
      final DateTime now = DateTime.now();
      final String date = "${now.year}-${now.month}-${now.day}";

      // Check if attendance for this student already exists for today
      final existingAttendance = await db.query(
        'attendance',
        where: 'roll_number = ? AND date = ?',
        whereArgs: [rollNumber, date],
      );

      if (existingAttendance.isEmpty) {
        await db.insert('attendance', {
          'roll_number': rollNumber,
          'date': date,
        });
      } else {
        throw Exception('Attendance already marked for today!');
      }
    } else {
      throw Exception('Student not found: $rollNumber');
    }
  }

  // Get all students (for listing or any other use case)
  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await _getDatabase();
    return await db.query('student');
  }

  // Fetch attendance for a student
  static Future<List<Map<String, dynamic>>> getAttendanceByRollNumber(String rollNumber) async {
    final db = await _getDatabase();
    return await db.query(
      'attendance',
      where: 'roll_number = ?',
      whereArgs: [rollNumber],
    );
  }
}
