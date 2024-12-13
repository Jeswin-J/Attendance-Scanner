import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'view_attendance.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  final List<String> scannedIds = [];

  void _addScanResult(String code) {
    setState(() {
      scannedIds.add(code);
    });
    Fluttertoast.showToast(
      msg: "ID Scanned: $code",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
                  builder: (context) => ViewAttendancePage(scannedIds: scannedIds),
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
            if (code != null && !scannedIds.contains(code)) {
              _addScanResult(code);
              break;
            }
          }
        },
      ),
    );
  }
}
