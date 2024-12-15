import 'package:contained_app/pages/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:contained_app/service/attendance_service.dart';
import 'package:fluttertoast/fluttertoast.dart';  // Import the fluttertoast package

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScanning = true;
  double scanLinePosition = 0;
  bool scanLineDirectionUp = true;
  bool isLineVisible = true;

  @override
  void initState() {
    super.initState();
    _startScanningLineEffect();
    _startBlinkingEffect();
  }

  void _navigateToReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportPage()),
    );
  }

  // Function to animate the scanning line
  void _startScanningLineEffect() {
    Future.doWhile(() async {
      if (!isScanning) return false;

      setState(() {
        if (scanLineDirectionUp) {
          scanLinePosition -= 5;
          if (scanLinePosition <= 0) scanLineDirectionUp = false;
        } else {
          scanLinePosition += 5;
          if (scanLinePosition >= 200) scanLineDirectionUp = true;
        }
      });

      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    });
  }

  // Function to make the scanning line blink
  void _startBlinkingEffect() {
    Future.doWhile(() async {
      if (!isScanning) return false;

      setState(() {
        isLineVisible = !isLineVisible;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

  // Function to show a toast message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Function to handle the barcode scan
  void _onScan(String rollNumber) async {
    try {
      await AttendanceService.markStudentAttendance(rollNumber);
      _showToast('Attendance marked: $rollNumber');
    } catch (e) {
      // Display a custom message based on the exception
      String message;
      if (e.toString().contains('Student not found')) {
        message = 'No student found: $rollNumber';
      } else if (e.toString().contains('Attendance already marked')) {
        message = 'Attendance already marked for $rollNumber';
      } else {
        message = 'An error occurred. Please try again later.';
      }

      _showToast(message);
    }
  }

  // Function to handle manual attendance
  void _markManualAttendance(String rollNumber) async {
    try {
      await AttendanceService.markStudentAttendance(rollNumber);
      _showToast('Attendance marked for $rollNumber');
    } catch (e) {
      String message;
      if (e.toString().contains('Student not found')) {
        message = 'No student found: $rollNumber';
      } else if (e.toString().contains('Attendance already marked')) {
        message = 'Attendance already marked for $rollNumber';
      } else {
        message = 'An error occurred. Please try again later.';
      }

      _showToast(message);
    }
  }

  // Function to show manual attendance input dialog
  void _showManualAttendanceDialog() {
    final TextEditingController rollNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: rollNumberController,
            decoration: const InputDecoration(
              labelText: 'Roll Number (Last 3-Digits)',
            ),
            keyboardType: TextInputType.number,
            maxLength: 3, // Limit to 3 digits
            inputFormatters: [
              // Allow only digits
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final rollNumber = rollNumberController.text.trim();

                if (rollNumber.isNotEmpty && rollNumber.length == 3) {
                  // Create the full roll number by appending the input to '2022PECCS'
                  final fullRollNumber = '2022PECCS$rollNumber';
                  _markManualAttendance(fullRollNumber);
                  Navigator.pop(context); // Close the dialog
                } else {
                  _showToast('Please enter a valid 3-digit roll number');
                }
              },
              child: const Text('Mark Attendance'),
            ),
          ],
        );
      },
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
            onPressed: _navigateToReport, // Navigate to ReportPage
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                // The scanner widget (camera feed)
                MobileScanner(
                  onDetect: (BarcodeCapture barcodeCapture) {
                    final barcode = barcodeCapture.barcodes.first;
                    if (barcode.rawValue != null) {
                      _onScan(barcode.rawValue!);  // Handle scan and mark attendance
                    }
                  },
                ),
                // Green bordered scanning box
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Stack(
                        children: [
                          // The blinking scanning line effect inside the box
                          Positioned(
                            top: scanLinePosition,
                            left: 0,
                            right: 0,
                            child: isLineVisible
                                ? Container(
                              height: 3,
                              color: Colors.red.withOpacity(0.7),
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Manual Attendance Button
          ElevatedButton(
            onPressed: _showManualAttendanceDialog,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,  // Set the background color to blue
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,  // Set border radius to zero
              ),
            ),
            child: const Text(
                'Manual Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}
