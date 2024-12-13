import 'package:flutter/material.dart';
import 'view_attendance.dart';

class ScanIdPage extends StatelessWidget {
  const ScanIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ID'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewAttendancePage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Scan Student ID Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
