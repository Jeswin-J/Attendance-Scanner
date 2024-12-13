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
  String? selectedDepartment;
  String? selectedVenue;
  List<Map<String, dynamic>> scannedStudentData = [];
  List<Map<String, dynamic>> filteredData = [];

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
        bool matchesDepartment = selectedDepartment == null || student['department'] == selectedDepartment;
        bool matchesVenue = selectedVenue == null || student['venue'] == selectedVenue;
        return matchesDepartment && matchesVenue;
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedDepartment,
                    hint: const Text("Select Department"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue;
                        _applyFilters();
                      });
                    },
                    items: ['ADS', 'AIML', 'CSBS', 'CSE', 'ECE', 'EEE', 'IT', 'MECH']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Venue Filter
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedVenue,
                    hint: const Text("Select Venue"),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedVenue = newValue;
                        _applyFilters();
                      });
                    },
                    items: ['IDEA_LAB', 'Genius Lounge', 'Coders Den', 'Thinkers Corner', 'Creative Chambers']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(student['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Roll Number: ${student['rollNumber']}'),
                              Text('Year: ${student['year']}'),
                              Text('Department: ${student['department']}'),
                              Text('Section: ${student['section']}'),
                              Text('Venue: ${student['venue']}'),
                            ],
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
