import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  // Firebase Database Reference
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  
  // Timetable Variables
  String? selectedTeacher;
  String? selectedTimetableDay;
  String? selectedTime;
  List<Map<String, String>> timetableResult = [];
  bool isDarkMode = false;
  bool isLoading = false;
  
  // Lists to be populated from Firebase
  List<String> teachers = [];
  List<String> times = ['8:00 - 9:00', '9:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00', '12:00 - 1:00', '1:00 - 2:00', '2:00 - 3:00', '3:00 - 4:00'];

  // Mapping between display names and Firebase keys
  final Map<String, String> _teacherKeyMap = {};
  final Map<String, String> _dayKeyMap = {
    'Monday': 'monday',
    'Tuesday': 'tuesday',
    'Wednesday': 'wednesday', 
    'Thursday': 'thursday',
    'Friday': 'friday'
  };

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      _loadTeachersFromFirebase();
    } catch (e) {
      print("Firebase initialization error: $e");
    }
  }

  // Load teachers list from Firebase
  Future<void> _loadTeachersFromFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _databaseRef.child('teachers').get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final teacherList = <String>[];
        _teacherKeyMap.clear();
        
        data.forEach((key, value) {
          final teacherKey = key.toString();
          final teacherName = value.toString();
          teacherList.add(teacherName);
          _teacherKeyMap[teacherName] = teacherKey;
        });
        
        setState(() {
          teachers = teacherList;
        });
      } else {
        // If no teachers found, use default list
        setState(() {
          teachers = ['Mr. Sharma', 'Ms. Gupta', 'Mr. Khan', 'Prof. Verma', 'Mrs. Singh'];
        });
      }
    } catch (e) {
      print("Error loading teachers: $e");
      setState(() {
        teachers = ['Mr. Sharma', 'Ms. Gupta', 'Mr. Khan', 'Prof. Verma', 'Mrs. Singh'];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load timetable data from Firebase
  Future<void> showTimetable() async {
    if (selectedTeacher == null || selectedTimetableDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Teacher and Day'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      timetableResult.clear();
    });

    try {
      // Convert display names to Firebase keys
      final teacherKey = _teacherKeyMap[selectedTeacher!];
      final dayKey = _dayKeyMap[selectedTimetableDay!];
      
      if (teacherKey == null || dayKey == null) {
        throw Exception('Could not find Firebase keys for selection');
      }

      final snapshot = await _databaseRef
          .child('timetable')
          .child(teacherKey)
          .child(dayKey)
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, String>> classes = [];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            classes.add({
              'time': value['time']?.toString() ?? '',
              'room': value['room']?.toString() ?? '',
              'subject': value['subject']?.toString() ?? 'General Class',
            });
          }
        });

        // Filter by selected time if specified
        if (selectedTime != null) {
          final filteredClasses = classes.where((lec) => lec['time'] == selectedTime).toList();
          setState(() {
            timetableResult = filteredClasses;
          });
          
          if (filteredClasses.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No lecture found for that time')),
            );
          }
        } else {
          setState(() {
            timetableResult = classes;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No classes found for this day')),
        );
        setState(() {
          timetableResult = [];
        });
      }
    } catch (e) {
      print("Error loading timetable: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetTimetableFields() {
    setState(() {
      selectedTeacher = null;
      selectedTimetableDay = null;
      selectedTime = null;
      timetableResult.clear();
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.indigo[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.indigo[600]! : Colors.indigo[200]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.indigo),
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Select $label',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.indigo[400],
                  ),
                ),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.indigo[900],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Faculty Timetable',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.indigo[900],
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.amber : Colors.indigo),
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    children: [
                      // Timetable Section - Only Card
                      Card(
                        elevation: 18,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        color: isDarkMode ? Colors.indigo[900] : Colors.white,
                        shadowColor: Colors.indigo.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: isDarkMode ? Colors.amber : Colors.indigo,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Teacher Timetable",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.indigo[900],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "View complete schedule of teachers",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.indigo[600],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Loading indicator for teachers
                              if (isLoading && teachers.isEmpty)
                                const Center(child: CircularProgressIndicator()),

                              // Teacher Dropdown
                              _buildDropdown('Teacher', selectedTeacher, teachers, (value) {
                                setState(() {
                                  selectedTeacher = value;
                                });
                              }),

                              const SizedBox(height: 20),

                              // Day Dropdown
                              _buildDropdown('Day', selectedTimetableDay, days, (value) {
                                setState(() {
                                  selectedTimetableDay = value;
                                });
                              }),

                              const SizedBox(height: 20),

                              // Time Dropdown (Optional)
                              _buildDropdown('Time Slot (Optional)', selectedTime, times, (value) {
                                setState(() {
                                  selectedTime = value;
                                });
                              }),

                              const SizedBox(height: 28),

                              // Action Buttons - FIXED WITH SHORTER TEXT
                              Container(
                                height: 56,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: resetTimetableFields,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          side: BorderSide(
                                            color: isDarkMode ? Colors.indigo[600]! : Colors.indigo,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 20,
                                              color: isDarkMode ? Colors.white : Colors.indigo,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Reset',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.indigo,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : showTimetable,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 4,
                                          shadowColor: Colors.indigo.withOpacity(0.3),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      'Show Schedule',
                                                      style: TextStyle(
                                                        fontSize: 15, // Slightly smaller font
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Loading indicator for timetable
                              if (isLoading && timetableResult.isEmpty)
                                const Center(child: CircularProgressIndicator()),

                              // Timetable Results
                              if (timetableResult.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: isDarkMode ? Colors.amber : Colors.indigo,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Timetable for $selectedTeacher',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode ? Colors.white : Colors.indigo[900],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Day: $selectedTimetableDay • ${timetableResult.length} classes',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white70 : Colors.indigo[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...timetableResult.map((lec) => Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: isDarkMode ? Colors.indigo[700] : Colors.white,
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.indigo[600] : Colors.indigo[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.school,
                                        color: isDarkMode ? Colors.amber : Colors.indigo,
                                      ),
                                    ),
                                    title: Text(
                                      lec['time']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.white : Colors.indigo[900],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Room: ${lec['room']}',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white70 : Colors.indigo[700],
                                          ),
                                        ),
                                        Text(
                                          'Subject: ${lec['subject']}',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white70 : Colors.indigo[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: isDarkMode ? Colors.amber : Colors.indigo,
                                      size: 16,
                                    ),
                                  ),
                                )).toList(),
                              ] else if (selectedTeacher != null && selectedTimetableDay != null && !isLoading) ...[
                                Container(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule_send,
                                        size: 64,
                                        color: isDarkMode ? Colors.indigo[300] : Colors.indigo[200],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No classes scheduled',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? Colors.white70 : Colors.indigo[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Select different day or time slot',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white54 : Colors.indigo[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sticky Quote at the bottom
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                color: Colors.transparent,
                child: Text(
                  "“Study not to pass the exam, but to empower your future.” 💡📖",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white70 : Colors.indigo[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}