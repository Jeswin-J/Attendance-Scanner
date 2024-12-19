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
    final path = join(databasePath, 'qspiders_attendance.db');

    if (await databaseExists(path)) {
      _database = await openDatabase(path);
    } else {
      await _copyDatabaseFromAssets(path);
      _database = await openDatabase(path);
    }

    return _database!;
  }

  // Fetch attendance data for a specific date, venue, and batch
  static Future<List<Map<String, dynamic>>> getAttendanceByBatchAndVenue(String date, String batch, String venue) async {
    final db = await _getDatabase();


    String whereClause = 'date = ?';
    List<String> whereArgs = [date];

    // Apply venue and batch filter
    if (venue.isNotEmpty) {
      whereClause += ' AND venue = ?';
      whereArgs.add(venue);
    }

    if (batch.isNotEmpty) {
      whereClause += ' AND batch = ?';
      whereArgs.add(batch);
    }

    // Query attendance with filters
    return await db.query(
      'attendance',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }


  static Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      final ByteData data = await rootBundle.load('assets/qspiders_attendance.db');
      final List<int> bytes = data.buffer.asUint8List();

      await File(path).writeAsBytes(bytes);
    } catch (e) {
      print("ERROR!!!!!");
      throw Exception("Failed to copy database: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentsByBatchAndVenue(
      String batch, String venue) async {
    final db = await _getDatabase();
    String whereClause;
    List<dynamic> whereArgs;

    print(venue);

    if (venue.toLowerCase() == 'auditorium') {
      // If the venue is 'auditorium', only filter by batch
      whereClause = 'batch = ?';
      whereArgs = [batch];
    } else {
      // For other venues, filter by both batch and venue
      whereClause = 'batch = ? AND venue = ?';
      whereArgs = [batch, venue];
    }

    return await db.query(
      'student',
      where: whereClause,
      whereArgs: whereArgs,
    );
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
  static Future<void> markAttendance(String rollNumber, String batch, String venue) async {
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
          'batch': batch,
          'venue': venue,
        });
      } else {
        throw Exception('Attendance already marked for today!');
      }
    } else {
      throw Exception('Student not found: $rollNumber');
    }
  }

  // Fetch absentees for a specific date
  static Future<List<Map<String, dynamic>>> getAbsenteesByDate(String date) async {
    final db = await _getDatabase();

    // Fetch all students
    final List<Map<String, dynamic>> allStudents = await db.query('student');

    // Fetch students who are present (attendance marked)
    final List<Map<String, dynamic>> presentStudents = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
      columns: ['roll_number'], // Only fetch roll numbers for comparison
    );

    // Convert present roll numbers into a Set for faster lookup
    final Set<String> presentRollNumbers =
    presentStudents.map((e) => e['roll_number'] as String).toSet();

    // Find absentees by filtering all students
    final List<Map<String, dynamic>> absentees = allStudents
        .where((student) => !presentRollNumbers.contains(student['roll_number']))
        .toList();

    return absentees;
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
