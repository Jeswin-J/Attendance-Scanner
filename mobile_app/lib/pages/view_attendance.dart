import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:attendance_scanner/services/api_service.dart';

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String searchQuery = '';
  bool showAbsenteesOnly = false;
  List<Map<String, dynamic>> scannedStudentData = [];
  List<Map<String, dynamic>> filteredData = [];
  int totalStrength = 566;
  int presentCount = 0;
  int absentCount = 0;
  bool isLoading = false; // Track loading state

  // Fetch Attendance Data
  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await ApiService.fetchAttendance(formattedDate);
      setState(() {
        scannedStudentData = response;
        presentCount = response.length;
        absentCount = totalStrength - presentCount;
        _applyFilters();
      });
        } catch (e) {
      _showErrorMessage('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  // Generate Attendance Report
  Future<String> _generateAttendanceReport() async {
    try {
      final absenteesData = await ApiService.fetchAbsentees(formattedDate);

      if (absenteesData.isEmpty) {
        return 'No absentees found for the selected date.';
      }

      Map<String, List<String>> venueAbsentees = {};
      for (var student in absenteesData) {
        String venue = student['venue'] ?? 'Unknown Venue';
        String registerNumber = student['registerNumber'];

        if (!venueAbsentees.containsKey(venue)) {
          venueAbsentees[venue] = [];
        }
        venueAbsentees[venue]!.add(registerNumber);
      }

      String venueDetails = '';
      venueAbsentees.forEach((venue, absentees) {
        venueDetails += '''
        
**************************
$venue
**************************
${absentees.join('\n')}
''';
      });

      return '''
🌷🌷🌷🌷🌷🌷🌷🌷
QSpider Attendance Details:
🌷🌷🌷🌷🌷🌷🌷🌷

Date                       : $formattedDate
Department          : CSE
Total Strength      : $totalStrength
No. of present      : $presentCount
No. of absentees : ${totalStrength - presentCount}

Venue wise attendance details:

$venueDetails
''';
    } catch (e) {
      return 'Error generating attendance report: $e';
    }
  }

  // Apply Filters
  void _applyFilters() {
    if (showAbsenteesOnly) {
      ApiService.fetchAbsentees(formattedDate).then((response) {
        setState(() {
          filteredData = response;
          absentCount = response.length;
        });
      }).catchError((e) {
        _showErrorMessage('Error applying filters: $e');
      });
    } else {
      setState(() {
        filteredData = scannedStudentData.where((student) {
          final matchesSearchQuery = searchQuery.isEmpty ||
              (student['department']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
              (student['venue']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
              (student['section']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
          return matchesSearchQuery;
        }).toList();
      });
    }
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
                  onPressed: () async {
                    final String report = await _generateAttendanceReport();
                    Clipboard.setData(ClipboardData(text: report));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance report copied to clipboard!')),
                    );
                  },
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
                                  student['rollNumber'] ?? 'Unknown',
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
