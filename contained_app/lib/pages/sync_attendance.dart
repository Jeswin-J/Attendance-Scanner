import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Importing the fluttertoast package
import 'package:contained_app/service/attendance_service.dart';

class SyncAttendancePage extends StatefulWidget {
  final Function onAttendanceUpdated;
  final String batch;
  final String venue;

  const SyncAttendancePage({super.key, required this.onAttendanceUpdated, required this.batch, required this.venue});

  @override
  _SyncAttendancePageState createState() => _SyncAttendancePageState();
}

class _SyncAttendancePageState extends State<SyncAttendancePage> {
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false; // Flag to show processing state
  String _errorMessage = ''; // To store error messages

  // Method to handle attendance sync
  Future<void> _syncAttendance() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = ''; // Clear previous error
    });

    try {
      // Get the roll numbers from the text field
      final rollNumbers = _textController.text.split(',').map((rollNumber) => rollNumber.trim()).toList();

      if (rollNumbers.isEmpty) {
        _showToast('Please enter at least one roll number.');
        return;
      }

      // Loop through each roll number to mark attendance
      for (String rollNumber in rollNumbers) {
        try {
          rollNumber = '2022PECCS$rollNumber';
          // Assuming `markAttendanceForStudent` is the method in your DB helper to mark attendance
          await AttendanceService.markStudentAttendance(rollNumber, widget.batch, widget.venue); // Adjust method signature if necessary
        } catch (e) {
          print("Error while marking attendance for $rollNumber: $e");
          continue; // Skip the student with an error
        }
      }

      // Show a success message if attendance for all students is processed
      _showToast('Attendance synced successfully!');

      // Pass success result to the previous page
      widget.onAttendanceUpdated(); // Update attendance on the parent page
      Navigator.pop(context, true); // Passing 'true' to indicate successful sync

    } catch (e) {
      print("Error during attendance sync: $e");
      _showToast(e.toString()); // Show the error message from the exception
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Show toast message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // Show for a short time
      gravity: ToastGravity.BOTTOM,    // Position the toast at the bottom
      timeInSecForIosWeb: 1,          // Duration for iOS Web
      backgroundColor: Colors.black,  // Toast background color
      textColor: Colors.white,        // Toast text color
      fontSize: 16.0,                 // Toast font size
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Attendance'),
      ),
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView to avoid overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste the roll numbers of the students (comma separated):',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35, // Takes up 40% of the screen height
                child: TextField(
                  controller: _textController,
                  maxLines: null, // Allow multiple lines
                  expands: true, // Make the TextField expand to fill the container
                  keyboardType: TextInputType.multiline, // Allow multiple lines of input
                  textAlignVertical: TextAlignVertical.top, // Align text to the top
                  decoration: const InputDecoration(
                    labelText: 'Roll Numbers',
                    hintText: '101, 102, 103',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _syncAttendance, // Disable button while processing
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // White text color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16), // Bold text
                  ),
                  child: const Text('Sync Attendance'),
                ),
              ),
              if (_isProcessing) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(), // Show progress bar while processing
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
