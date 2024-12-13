import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'view_attendance.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  final List<Map<String, dynamic>> scannedStudentData = [];

  void _addScanResult(String code) async {
    final responseData = await ApiService.checkIn(code);

    if (responseData != null && responseData['success']) {
      setState(() {
        scannedStudentData.add(responseData['data']['student']);
      });

      Fluttertoast.showToast(
        msg: "Scanned Id: $code",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to mark attendance",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

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
                MaterialPageRoute(
                  builder: (context) => ViewAttendancePage(
                    scannedStudentData: scannedStudentData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null && !scannedStudentData.any((student) => student['rollNumber'] == code)) {
              _addScanResult(code);
              break;
            }
          }
        },
      ),
    );
  }
}
