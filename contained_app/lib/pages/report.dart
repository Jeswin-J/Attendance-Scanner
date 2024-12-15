import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:contained_app/utils/database_helper.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String searchQuery = '';
  bool showAbsenteesOnly = false;
  List<Map<String, dynamic>> scannedStudentData = [];
  List<Map<String, dynamic>> filteredData = [];
  int totalStrength = 0;
  int presentCount = 0;
  int absentCount = 0;
  bool isLoading = false; // Track loading state

  // Fetch Attendance Data from SQLite
  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Fetch all students
      final List<Map<String, dynamic>> students = await DatabaseHelper.getAllStudents();

      totalStrength = students.length;

      // Fetch attendance data for the selected date
      final List<Map<String, dynamic>> attendance = await DatabaseHelper.getAttendanceByDate(formattedDate);

      // List of present student roll numbers
      final Set<String> presentRollNumbers = attendance.map((entry) => entry['roll_number'] as String).toSet();

      // Determine present and absent students
      scannedStudentData = students.map((student) {
        final rollNumber = student['roll_number'] as String;
        final isPresent = presentRollNumbers.contains(rollNumber);
        return {...student, 'isPresent': isPresent};
      }).toList();

      presentCount = scannedStudentData.where((student) => student['isPresent'] == true).length;
      absentCount = totalStrength - presentCount;

      _applyFilters();
    } catch (e) {
      _showErrorMessage('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  String _generateAttendanceReport() {
    // Prepare the attendance report
    StringBuffer reportBuffer = StringBuffer();

    reportBuffer.writeln('🌷🌷🌷🌷🌷🌷🌷🌷');
    reportBuffer.writeln('QSpider Attendance Details:');
    reportBuffer.writeln('🌷🌷🌷🌷🌷🌷🌷🌷');
    reportBuffer.writeln();
    reportBuffer.writeln('Date                      : $formattedDate');
    reportBuffer.writeln('Department          : CSE');
    reportBuffer.writeln('Total Strength      : $totalStrength');
    reportBuffer.writeln('No. of present      : $presentCount');
    reportBuffer.writeln('No. of absentees : $absentCount');
    reportBuffer.writeln();
    reportBuffer.writeln('****************************');
    reportBuffer.writeln('AUDITORIUM ABSENTEES');
    reportBuffer.writeln('****************************');

    // Add roll numbers of absent students
    final absentStudents = scannedStudentData
        .where((student) => student['isPresent'] == false)
        .map((student) => student['roll_number'])
        .toList();

    absentStudents.forEach((rollNumber) {
      reportBuffer.writeln(rollNumber);
    });

    return reportBuffer.toString();
  }

  void _copyReportToClipboard() {
    final report = _generateAttendanceReport();
    Clipboard.setData(ClipboardData(text: report)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report copied to clipboard!')),
      );
    });
  }

  // Apply Filters
  void _applyFilters() {
    setState(() {
      // Filter the data based on the "Show Absentees" checkbox and search query
      filteredData = scannedStudentData.where((student) {
        final matchesSearchQuery = searchQuery.isEmpty ||
            (student['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['roll_number']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['department']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['section']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['venue']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        final matchesAbsentees = showAbsenteesOnly ? student['isPresent'] == false : student['isPresent'] == true;

        return matchesSearchQuery && matchesAbsentees;
      }).toList();
    });
  }


  // Show Error Message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
      _fetchAttendanceData();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading Indicator
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search & Filter',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Show Absentees Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: showAbsenteesOnly,
                  onChanged: (value) {
                    setState(() {
                      showAbsenteesOnly = value!;
                      _applyFilters();
                    });
                  },
                ),
                const Text('Show Absentees'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: _copyReportToClipboard,
                ),
              ],
            ),
          ),

          // Statistics Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              color: Colors.blueAccent.shade200,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Present Count
                        Column(
                          children: [
                            const Text(
                              'Total Present',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$presentCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Attendance Percentage
                        Column(
                          children: [
                            const Text(
                              'Attendance %',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalStrength > 0
                                  ? ((presentCount / totalStrength) * 100).toStringAsFixed(1)
                                  : '0',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List of Students
          Expanded(
            child: filteredData.isEmpty
                ? const Center(child: Text('No data available'))
                : ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final student = filteredData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          student['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  student['roll_number'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '${student['year'] ?? 'N/A'} ${student['department'] ?? 'Unknown'} ${student['section'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: Text(
                                    student['venue'] ?? 'Unknown Venue',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
