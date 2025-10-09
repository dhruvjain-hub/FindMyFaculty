import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> teacherNames = [
    'Dr. Sharma',
    'Ms. Gupta',
    'Mr. Khan',
    'Prof. Verma',
    'Mrs. Singh',
    'Dr. Patel',
    'Ms. Roy',
    'Mr. Das',
    'Prof. Mehta',
    'Mrs. Joshi',
  ];

  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isDarkMode = false;
  String searchQuery = '';

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.indigo[900]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final int selectedMinutes = picked.hour * 60 + picked.minute;
      const int minMinutes = 8 * 60;
      const int maxMinutes = 15 * 60;

      if (selectedMinutes < minMinutes || selectedMinutes > maxMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select time between 8:00 AM and 3:00 PM'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        if (isStart) {
          startTime = picked;
          endTime ??= TimeOfDay(
            hour: (picked.hour + 1).clamp(8, 15),
            minute: picked.minute,
          );
        } else {
          endTime = picked;
        }
      });
    }
  }

  void resetFields() {
    setState(() {
      selectedDay = null;
      startTime = null;
      endTime = null;
      searchQuery = '';
    });
  }

  void swapTimes() {
    if (startTime != null && endTime != null) {
      setState(() {
        final temp = startTime;
        startTime = endTime;
        endTime = temp;
      });
    }
  }

  bool validateTime() {
    if (startTime == null || endTime == null) return false;
    final start = Duration(hours: startTime!.hour, minutes: startTime!.minute);
    final end = Duration(hours: endTime!.hour, minutes: endTime!.minute);
    return end > start;
  }

  void goToResults() {
    if (selectedDay == null) {
      _showSnackBar("Please select a day");
      return;
    }

    if (startTime == null || endTime == null) {
      _showSnackBar("Please select both start and end time");
      return;
    }

    if (!validateTime()) {
      _showSnackBar("End time should be after start time");
      return;
    }

    Navigator.pushNamed(
      context,
      '/results',
      arguments: {
        'day': selectedDay,
        'startTime': startTime,
        'endTime': endTime,
        'searchQuery': searchQuery,
      },
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: isDarkMode
          ? [Colors.indigo[900]!, Colors.black]
          : [Colors.indigo[100]!, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final List<String> suggestions = searchQuery.isEmpty
        ? []
        : teacherNames
            .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Find My Faculty',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.indigo[900],
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: isDarkMode ? Colors.amber : Colors.indigo),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                Card(
                  elevation: 18,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  color: isDarkMode ? Colors.indigo[900] : Colors.white,
                  shadowColor: Colors.indigo.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Check Teacher Availability",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.indigo[900],
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.indigo[900],
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search teacher by name or keyword...',
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.white54 : Colors.indigo[300],
                            ),
                            prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.amber : Colors.indigo),
                            filled: true,
                            fillColor: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    suggestions[index],
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.indigo[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      searchQuery = suggestions[index];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Day',
                            labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.indigo),
                            filled: true,
                            fillColor: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          dropdownColor: isDarkMode ? Colors.indigo[800] : Colors.white,
                          value: selectedDay,
                          items: days.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.indigo[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedDay = val),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => pickTime(true),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.indigo[200]!),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    startTime != null
                                        ? 'Start: ${formatTime(startTime!)}'
                                        : 'Start Time',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.indigo[900],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              icon: Icon(Icons.swap_horiz, color: isDarkMode ? Colors.amber : Colors.indigo),
                              tooltip: "Swap",
                              onPressed: swapTimes,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => pickTime(false),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                                    border: Border.all(color: isDarkMode ? Colors.white24 : Colors.indigo[200]!),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    endTime != null
                                        ? 'End: ${formatTime(endTime!)}'
                                        : 'End Time',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.indigo[900],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: resetFields,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode ? Colors.indigo[700] : Colors.indigo[200],
                                  foregroundColor: isDarkMode ? Colors.white : Colors.indigo[900],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: goToResults,
                                icon: const Icon(Icons.search),
                                label: const Text('Find Teachers'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode ? Colors.amber : Colors.indigo,
                                  foregroundColor: isDarkMode ? Colors.indigo[900] : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
