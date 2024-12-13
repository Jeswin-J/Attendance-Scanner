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
  List<Map<String, dynamic>> scannedStudentData = [];
  List<Map<String, dynamic>> filteredData = [];

  final Map<String, String> venueMap = {
    'Idea Lab': 'IDEA_LAB',
    'Genius Lounge': 'GENIUS_LOUNGE',
    'Coders Den': 'CODERS_DEN',
    'Thinkers Corner': 'THINKERS_CORNER',
    'Creative Chambers': 'CREATIVE_CHAMBERS',
  };

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await ApiService.fetchAttendance(formattedDate);
      setState(() {
        scannedStudentData = response;
        filteredData = List.from(scannedStudentData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _applyFilters() {
    setState(() {
      filteredData = scannedStudentData.where((student) {
        // Normalize both search query and fields (replace underscores with spaces)
        final searchLower = searchQuery.toLowerCase().replaceAll('_', ' ');
        final department = (student['department']?.toLowerCase().replaceAll('_', ' ') ?? '');
        final venue = (student['venue']?.toLowerCase().replaceAll('_', ' ') ?? '');
        final section = (student['section']?.toLowerCase().replaceAll('_', ' ') ?? '');

        // Check if the search query matches any of the fields
        return department.contains(searchLower) || venue.contains(searchLower) || section.contains(searchLower);
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters(); // Apply filter as the user types
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search & Filter',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.fetchAttendance(formattedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  final scannedStudentData = snapshot.data!;
                  return ListView.builder(
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
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
