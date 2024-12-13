import 'package:flutter/material.dart';

class ViewAttendancePage extends StatelessWidget {
  const ViewAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Attendance Records Displayed Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
