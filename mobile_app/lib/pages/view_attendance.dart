import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int totalStrength = 0;
  int presentCount = 0;
  int absentCount = 0;

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await ApiService.fetchAttendance(formattedDate);
      setState(() {
        scannedStudentData = response;
        totalStrength = response.length; // Assuming this is the total strength
        presentCount = response.where((student) => student['status'] == 'present').length;
        absentCount = totalStrength - presentCount;
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _applyFilters() {
    setState(() {
      filteredData = scannedStudentData.where((student) {
        final matchesSearchQuery = searchQuery.isEmpty ||
            (student['department']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['venue']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['section']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        final matchesAbsenteesFilter =
            !showAbsenteesOnly || (student['status'] == 'absent'); // Filter absentees

        return matchesSearchQuery && matchesAbsenteesFilter;
      }).toList();
    });
  }

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
                          student['name'],
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
                                  student['rollNumber'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '${student['year']} ${student['department']} ${student['section']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  student['venue'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
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

  Widget _buildStatCard(String label, dynamic value, Color color) {
    return Card(
      elevation: 4,
      color: color,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
