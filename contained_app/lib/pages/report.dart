import 'package:contained_app/pages/sync_attendance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:contained_app/utils/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportPage extends StatefulWidget {

  final String batch;
  final String venue;

  const ReportPage({super.key, required this.batch, required this.venue});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String reportDate =  DateFormat('dd-MM-yyyy').format(DateTime.now());
  String searchQuery = '';
  bool showAbsenteesOnly = false;
  List<Map<String, dynamic>> scannedStudentData = [];
  List<Map<String, dynamic>> filteredData = [];
  int totalStrength = 0;
  int presentCount = 0;
  int absentCount = 0;
  int venueStudentsCount = 0;


  final Map<String, Map<String, Map<String, int>>> totalStrengths = {};

  Future<void> _fetchAttendanceData() async {

    try {
      // Fetch all students
      final List<Map<String, dynamic>> venueStudents = await DatabaseHelper.getStudentsByBatchAndVenue(widget.batch, widget.venue);
      final List<Map<String, dynamic>> students = await DatabaseHelper.getAllStudents();


      totalStrength = students.length;
      venueStudentsCount = venueStudents.length;

      for (final student in students) {
        final batch = student['batch'];
        final venue = student['venue'];
        final gender = student['gender'];

        if (!totalStrengths.containsKey(batch)) {
          totalStrengths[batch] = {};
        }

        if (!totalStrengths[batch]!.containsKey(venue)) {
          totalStrengths[batch]![venue] = {'Boys': 0, 'Girls': 0};
        }

        if (gender == 'M') {
          totalStrengths[batch]![venue]!['Boys'] =
              (totalStrengths[batch]![venue]!['Boys'] ?? 0) + 1;
        } else if (gender == 'F') {
          totalStrengths[batch]![venue]!['Girls'] =
              (totalStrengths[batch]![venue]!['Girls'] ?? 0) + 1;
        }

      }

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
    }
  }

  String _generateAttendanceReport() {
    String attendancePercent = ((presentCount / totalStrength) * 100).toStringAsFixed(2);

    // Prepare the attendance report
    StringBuffer reportBuffer = StringBuffer();

    // Header Section
    reportBuffer.writeln('🌷🌷🌷🌷🌷🌷🌷🌷🌷🌷');
    reportBuffer.writeln('*QSpider Attendance Details:*');
    reportBuffer.writeln('🌷🌷🌷🌷🌷🌷🌷🌷🌷🌷');
    reportBuffer.writeln();
    reportBuffer.writeln('Date : $reportDate');
    reportBuffer.writeln('Department          : CSE');
    reportBuffer.writeln('Total Strength       : $totalStrength');
    reportBuffer.writeln('No. of present      : $presentCount');
    reportBuffer.writeln('No. of absentees  : $absentCount');
    reportBuffer.writeln('Attendance %       : $attendancePercent %');
    reportBuffer.writeln();

    // Section for batch-wise details
    reportBuffer.writeln('*******************************');
    reportBuffer.writeln('Batch-wise absentees details:');
    reportBuffer.writeln('*******************************');

    // Group absentees by batch and venue
    final Map<String, Map<String, Map<String, List<String>>>> absenteesByBatchAndVenue = {};

    for (final student in scannedStudentData.where((s) => s['isPresent'] == false)) {
      final batch = student['batch'] ?? 'Unknown';
      final venue = student['venue'] ?? 'Unknown';
      final rollNumber = student['register_number'] ?? 'Unknown';
      final gender = (student['gender'] == 'F') ? 'Girls' : 'Boys';

      // Group by batch, venue, and gender
      absenteesByBatchAndVenue.putIfAbsent(batch, () => {});
      absenteesByBatchAndVenue[batch]?.putIfAbsent(venue, () => {'Boys': [], 'Girls': []});
      absenteesByBatchAndVenue[batch]?[venue]?[gender]?.add(rollNumber);
    }

    // Generate report for each batch-venue combination
    absenteesByBatchAndVenue.forEach((batch, venueMap) {
      venueMap.forEach((venue, genderMap) {
        reportBuffer.writeln();

        // Dynamically get total strength for the batch and venue
        final batchVenueStrength = totalStrengths[batch]?[venue];
        final totalBoysInVenue = batchVenueStrength?['Boys'] ?? 0;
        final totalGirlsInVenue = batchVenueStrength?['Girls'] ?? 0;
        final totalCombinedStrength = totalBoysInVenue + totalGirlsInVenue;

        // Write combined absentees and total strength
        reportBuffer.writeln(
            'Batch $batch ($venue): *${(genderMap['Boys']?.length ?? 0) + (genderMap['Girls']?.length ?? 0)} / $totalCombinedStrength*');

        // Boys Section
        final boys = genderMap['Boys'] ?? [];
        if (boys.isNotEmpty) {
          reportBuffer.writeln('\n  Boys : *${boys.length} / $totalBoysInVenue*');
          for (final rollNumber in boys) {
            reportBuffer.writeln('    $rollNumber');
          }
        }

        // Girls Section
        final girls = genderMap['Girls'] ?? [];
        if (girls.isNotEmpty) {
          reportBuffer.writeln('\n  Girls : *${girls.length} / $totalGirlsInVenue*');
          for (final rollNumber in girls) {
            reportBuffer.writeln('    $rollNumber');
          }
        }
      });
    });

    print(totalStrengths);

    return reportBuffer.toString();
  }




  // Apply Filters
  void _applyFilters() {
    setState(() {
      // Filter the data based on the "Show Absentees" checkbox and search query
      filteredData = scannedStudentData.where((student) {
        final matchesSearchQuery = searchQuery.isEmpty ||
            (student['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['register_number']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['department']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['section']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            (student['venue']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

        final matchesAbsentees = showAbsenteesOnly
            ? student['isPresent'] == false &&
            (widget.venue == 'Auditorium'
                ? student['batch'] == widget.batch
                : student['venue'] == widget.venue && student['batch'] == widget.batch)
            : student['isPresent'] == true &&
            (widget.venue == 'Auditorium'
                ? student['batch'] == widget.batch
                : student['venue'] == widget.venue && student['batch'] == widget.batch);

        return matchesSearchQuery && matchesAbsentees;
      }).toList();
    });
  }



  // Show Error Message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Copy the report to clipboard
  void _copyReportToClipboard() {
    final report = _generateAttendanceReport();
    Clipboard.setData(ClipboardData(text: report)).then((_) {
      _showErrorMessage('Attendance report copied to clipboard!');
    });
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
        title: const Text('Report'),
        actions: [
          IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy Attendance Report',
          onPressed: _copyReportToClipboard,
        ),],
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
                const Spacer(),
                IconButton(
                  tooltip: "Share",
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () async {
                    try {
                      // Extract roll numbers of present students
                      final presentStudents = scannedStudentData
                          .where((student) => student['isPresent'] == true)
                          .map((student) => student['roll_number'].toString().substring(student['roll_number'].toString().length - 3))
                          .whereType<String>()
                          .toList();

                      // Check if there are present students to share
                      if (presentStudents.isEmpty) {
                        _showErrorMessage('No present students to share.');
                        return;
                      }

                      // Format roll numbers into a message
                      final rollNumbers = presentStudents.join(', ');
                      final smsMessage = Uri.encodeComponent(rollNumbers);

                      // Launch SMS app with pre-filled message
                      final smsUri = Uri.parse('sms:?body=$smsMessage');

                      if (!await launchUrl(smsUri)) {
                        _showErrorMessage('Could not launch SMS app.');
                      }
                    } catch (e) {
                      _showErrorMessage('Error while sharing: $e');
                    }
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Batch ${widget.batch}, ${widget.venue}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              'Total Strength',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              venueStudentsCount.toString(),
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
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        contentPadding: const EdgeInsets.all(4),
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
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  student['register_number'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  '${student['year'] ?? 'N/A'} ${student['department'] ?? 'Unknown'} ${student['section'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 15),
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
          // Add this after the ListView.builder widget
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // White text color
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16), // Bold text
              ),
              onPressed: () {
                // Navigate to the SyncAttendancePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SyncAttendancePage(
                    batch: widget.batch,
                    venue: widget.venue,
                    onAttendanceUpdated: _fetchAttendanceData,
                  )),
                );
              },
              child: const Text('Sync Attendance'),
            ),
          ),

        ],
      ),
    );
  }
}
