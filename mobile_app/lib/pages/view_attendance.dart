import 'package:flutter/material.dart';

class ViewAttendancePage extends StatelessWidget {
  final List<Map<String, dynamic>> scannedStudentData;

  const ViewAttendancePage({super.key, required this.scannedStudentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance View'),
      ),
      body: ListView.builder(
        itemCount: scannedStudentData.length,
        itemBuilder: (context, index) {
          final student = scannedStudentData[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(student['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roll Number: ${student['rollNumber']}'),
                  Text('Year: ${student['year']}'),
                  Text('Department: ${student['department']}'),
                  Text('Section: ${student['section']}'),
                  Text('Venue: ${student['venue']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
