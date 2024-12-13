import 'package:attendance_scanner/pages/view_attendance.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class ScanIdPage extends StatefulWidget {
  const ScanIdPage({super.key});

  @override
  State<ScanIdPage> createState() => _ScanIdPageState();
}

class _ScanIdPageState extends State<ScanIdPage> {
  MobileScannerController cameraController = MobileScannerController();
  String? toastMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      _showToast("Camera permission is required.");
    } else {
      try {
        cameraController.start(); // Start the camera
      } catch (e) {
        print("Error starting camera: $e");
        _showToast("Failed to start the camera. Please check permissions.");
      }
    }
  }

  @override
  void dispose() {
    try {
      cameraController.stop(); // Stop the camera when the widget is disposed
    } catch (e) {
      print("Error stopping camera: $e");
    }
    super.dispose();
  }

  void _showToast(String message) {
    setState(() {
      toastMessage = message;
    });

    // Hide the toast after a few seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          toastMessage = null;
        });
      }
    });
  }

  void _addScanResult(String code) async {
    try {
      final responseData = await ApiService.checkIn(code);
      if (responseData == null) {
        _showToast("No response from the server");
        return;
      }

      final statusCode = responseData['statusCode'] ?? -1;
      final message = responseData['message'] ?? "Unknown error";

      if (statusCode == 0) {
        _showToast("Success: $code");
      } else if (statusCode == -1) {
        _showToast("Attendance Already Marked: $code");
      } else {
        _showToast("Error: $message");
      }
    } catch (e) {
      _showToast("An error occurred: $e");
      print("Error during check-in: $e");  // Log the error for debugging
    }
  }

  // Method to handle manual roll number entry
  void _manualCheckIn(BuildContext context) {
    TextEditingController rollNumberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Reduced border radius
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Button ("X")
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) {
                        Navigator.pop(context); // Close the dialog
                      }
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Input Field
                TextField(
                  controller: rollNumberController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Roll Number',
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                // "Mark Attendance" Button
                SizedBox(
                  width: double.infinity, // Make the button full-width
                  child: ElevatedButton(
                    onPressed: () {
                      final rollNumber = rollNumberController.text.trim();
                      if (rollNumber.isNotEmpty) {
                        _addScanResult(rollNumber);
                        if (mounted) {
                          Navigator.pop(context); // Close the dialog
                        }
                      } else {
                        _showToast("Please enter a roll number");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Transparent background
                      shadowColor: Colors.transparent, // No shadow
                      side: BorderSide(color: Colors.green), // Green border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0), // Rounded button
                      ),
                    ),
                    child: const Text(
                      'Mark Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Green text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ID Card'),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 4 / 5,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (barcodeCapture) {
                      final barcodes = barcodeCapture.barcodes;
                      for (final barcode in barcodes) {
                        final String? code = barcode.rawValue;
                        if (code != null) {
                          _addScanResult(code); // Process the barcode
                          break; // Stop after the first barcode is found
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _manualCheckIn(context), // Trigger manual check-in dialog
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Set button background color to blue
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.00)),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Make button width fill the available space
                    ),
                    child: const Text(
                      'Manual Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Custom toast message at the top inside the camera container
          if (toastMessage != null)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  toastMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
