import 'package:attendance_scanner/pages/view_attendance.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  MobileScannerController cameraController = MobileScannerController(); // Controller to manage the camera

  @override
  void initState() {
    super.initState();
    cameraController.start(); // Start the camera when the page is loaded
  }

  @override
  void dispose() {
    cameraController.stop(); // Stop the camera when the page is disposed
    super.dispose();
  }

  void _addScanResult(String code) async {
    try {
      final responseData = await ApiService.checkIn(code);

      final statusCode = responseData['statusCode'];
      final message = responseData['message'];

      if (statusCode == 0) {
        Fluttertoast.showToast(
          msg: "Success: $code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if (statusCode == -1) {
        Fluttertoast.showToast(
          msg: "Attendance Marked: $code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.yellow.shade200,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: $code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // If there is an exception, show a red error toast
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
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
                  builder: (context) => const ViewAttendancePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController, // Use the controller to manage the camera
        onDetect: (barcodeCapture) {
          final barcodes = barcodeCapture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              _addScanResult(code);
              break;
            }
          }
        },
      ),
    );
  }
}
