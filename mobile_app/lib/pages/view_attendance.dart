import 'package:flutter/material.dart';

class ViewAttendancePage extends StatelessWidget {
  final List<String> scannedIds;

  const ViewAttendancePage({super.key, required this.scannedIds});

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
      body: ListView.builder(
        itemCount: scannedIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('Student ID: ${scannedIds[index]}'),
          );
        },
      ),
    );
  }
}
