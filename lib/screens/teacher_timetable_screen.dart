import 'package:flutter/material.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final List<String> teachers = ['Mr. Sharma', 'Ms. Gupta', 'Mr. Khan', 'Prof. Verma', 'Mrs. Singh'];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> times = [
    '9:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 1:00',
    '2:00 - 3:00',
    '3:00 - 4:00',
  ];

  final TextEditingController searchController = TextEditingController();

  String? selectedTeacher;
  String? selectedDay;
  String? selectedTime;

  List<Map<String, String>> result = [];

  // 📚 Sample Timetable Data
  final Map<String, Map<String, List<Map<String, String>>>> timetable = {
    'Mr. Sharma': {
      'Monday': [
        {'time': '9:00 - 10:00', 'room': '101'},
        {'time': '10:00 - 11:00', 'room': '102'},
        {'time': '11:00 - 12:00', 'room': '103'},
        {'time': '12:00 - 1:00', 'room': '104'},
        {'time': '2:00 - 3:00', 'room': '105'},
        {'time': '3:00 - 4:00', 'room': '106'},
      ],
      'Tuesday': [
        {'time': '9:00 - 10:00', 'room': '201'},
        {'time': '10:00 - 11:00', 'room': '202'},
        {'time': '11:00 - 12:00', 'room': '203'},
        {'time': '12:00 - 1:00', 'room': '204'},
        {'time': '2:00 - 3:00', 'room': '205'},
        {'time': '3:00 - 4:00', 'room': '206'},
      ],
    },
    'Ms. Gupta': {
      'Monday': [
        {'time': '9:00 - 10:00', 'room': '301'},
        {'time': '10:00 - 11:00', 'room': '302'},
        {'time': '11:00 - 12:00', 'room': '303'},
        {'time': '12:00 - 1:00', 'room': '304'},
        {'time': '2:00 - 3:00', 'room': '305'},
        {'time': '3:00 - 4:00', 'room': '306'},
      ],
    },
  };

  // 🧠 Logic to Show Timetable
  void showTimetable() {
    result.clear();

    if (selectedTeacher == null || selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Teacher and Day'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final teacherData = timetable[selectedTeacher];
    if (teacherData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available for this teacher')),
      );
      return;
    }

    final dayData = teacherData[selectedDay];
    if (dayData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No classes found for this day')),
      );
      return;
    }

    // If time is selected → show specific lecture
    if (selectedTime != null) {
      result = dayData.where((lec) => lec['time'] == selectedTime).toList();
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No lecture found for that time')),
        );
      }
    } else {
      // Else show all lectures
      result = List<Map<String, String>>.from(dayData);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Timetable'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Teacher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                selectedTeacher = teachers.firstWhere(
                  (t) => t.toLowerCase().contains(value.toLowerCase()),
                  orElse: () => '',
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // 👩‍🏫 Teacher Dropdown
            DropdownButtonFormField<String>(
              value: selectedTeacher,
              hint: const Text('Select Teacher'),
              items: teachers.map((teacher) {
                return DropdownMenuItem(value: teacher, child: Text(teacher));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTeacher = value;
                  searchController.text = value ?? '';
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // 📅 Day Dropdown
            DropdownButtonFormField<String>(
              value: selectedDay,
              hint: const Text('Select Day'),
              items: days.map((day) {
                return DropdownMenuItem(value: day, child: Text(day));
              }).toList(),
              onChanged: (value) => setState(() => selectedDay = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // ⏰ Time Dropdown (Optional)
            DropdownButtonFormField<String>(
              value: selectedTime,
              hint: const Text('Select Time (Optional)'),
              items: times.map((time) {
                return DropdownMenuItem(value: time, child: Text(time));
              }).toList(),
              onChanged: (value) => setState(() => selectedTime = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // 🔘 Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: showTimetable,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text('Show Timetable'),
              ),
            ),
            const SizedBox(height: 20),

            // 📋 Results
            Expanded(
              child: result.isEmpty
                  ? const Center(child: Text('No data to display'))
                  : ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        final lec = result[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.schedule, color: Colors.indigo),
                            title: Text('Time: ${lec['time']}'),
                            subtitle: Text('Room No: ${lec['room']}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}