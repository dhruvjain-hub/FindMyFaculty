import 'package:flutter/material.dart';
import 'faculty_info_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> _teachersStream = FirebaseFirestore.instance
      .collection('teachers')
      .where('isActive', isEqualTo: true)
      .snapshots();

  final Stream<QuerySnapshot> _timetableStream = FirebaseFirestore.instance
      .collection('timetable')
      .where('isActive', isEqualTo: true)
      .snapshots();

  // Firebase Database Reference

  // Timetable Variables
  String? selectedTeacher;
  String? selectedTimetableDay;
  String? selectedTime;
  String? selectedTeacherName;

  List<Map<String, String>> timetableResult = [];
  bool isDarkMode = false;
  bool isLoading = false;

  // Drawer state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // View mode
  String currentView = 'Timetable';

  // Lists to be populated from Firebase

  // Mapping between display names and Firebase keys

  // Initialize Firebase

  // Load teachers list from Firebase

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
      Query query = FirebaseFirestore.instance
          .collection('timetable')
          .where('teacherId', isEqualTo: selectedTeacher)
          .where('day', isEqualTo: selectedTimetableDay)
          .where('isActive', isEqualTo: true);

      if (selectedTime != null) {
        query = query.where('time', isEqualTo: selectedTime);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No classes found')));
      } else {
        final results = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'time': data['time']?.toString() ?? '',
            'room': data['room']?.toString() ?? '',
            'subject': data['subject']?.toString() ?? '',
          };
        }).toList();

        setState(() {
          timetableResult = results;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading timetable: $e'),
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
      selectedTeacherName = null;
      selectedTimetableDay = null;
      selectedTime = null;
      timetableResult.clear();
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.indigo),
    );
  }

  void _openFacultyInfoScreen() {
    _scaffoldKey.currentState?.closeDrawer();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyInfoScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    Map<String, String>? displayMap,
  }) {
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
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDarkMode ? Colors.white : Colors.indigo,
              ),
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
                      displayMap != null ? (displayMap[item] ?? item) : item,
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

  // Build the beautiful drawer
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: isDarkMode ? Colors.indigo[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.indigo[900]!, Colors.purple[900]!]
                : [Colors.indigo[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.indigo[700]!, Colors.purple[700]!]
                      : [Colors.indigo, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () {
                        _scaffoldKey.currentState?.closeDrawer();
                      },
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Faculty Timetable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage Your View',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Change View Section
                    _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: 'Teacher View',
                      subtitle: 'Switch to teacher view',
                      isSelected: true,
                      onTap: _openFacultyInfoScreen,
                    ),

                    const Spacer(),

                    // App Info
                    // Credits Section
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.indigo[800]
                            : Colors.indigo[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Developed by',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.indigo[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dhruv, Ankit, Arpit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.amber
                                  : Colors.indigo[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2025 All Rights Reserved',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.indigo[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDarkMode ? Colors.indigo[700] : Colors.indigo[100])
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: isSelected
            ? Border.all(
                color: isDarkMode ? Colors.amber : Colors.indigo,
                width: 2,
              )
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.indigo[600] : Colors.indigo[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDarkMode ? Colors.amber : Colors.indigo),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.indigo[900],
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.indigo[600],
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDarkMode ? Colors.white54 : Colors.indigo[400],
          size: 16,
        ),
        onTap: onTap,
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

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.indigo[800]
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.menu,
              color: isDarkMode ? Colors.amber : Colors.indigo,
            ),
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
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
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.indigo[800]
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.amber : Colors.indigo,
              ),
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
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
                                    color: isDarkMode
                                        ? Colors.amber
                                        : Colors.indigo,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Teacher Timetable",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.indigo[900],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "View complete schedule of teachers",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.indigo[600],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Teacher Dropdown
                              StreamBuilder<QuerySnapshot>(
                                stream: _teachersStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error loading teachers');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final teacherDocs = snapshot.data!.docs;

                                  final teacherMap = {
                                    for (var doc in teacherDocs)
                                      doc.id: doc['name'] as String,
                                  };

                                  return _buildDropdown(
                                    'Teacher',
                                    selectedTeacher,
                                    teacherMap.keys.toList(),
                                    (value) {
                                      setState(() {
                                        selectedTeacher = value;
                                        selectedTeacherName = teacherMap[value];
                                      });
                                    },
                                    displayMap:
                                        teacherMap, // ✅ YAHAN HONA CHAHIYE
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Day Dropdown
                              StreamBuilder<QuerySnapshot>(
                                stream: _timetableStream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  final docs = snapshot.data!.docs;
                                  final daySet = <String>{};

                                  for (var doc in docs) {
                                    final day = doc['day'];
                                    if (day != null &&
                                        day.toString().isNotEmpty) {
                                      daySet.add(day.toString());
                                    }
                                  }

                                  final dynamicDays = daySet.toList()..sort();

                                  return _buildDropdown(
                                    'Day',
                                    selectedTimetableDay,
                                    dynamicDays,
                                    (value) {
                                      setState(() {
                                        selectedTimetableDay = value;
                                      });
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Time Dropdown (Optional)
                              StreamBuilder<QuerySnapshot>(
                                stream: _timetableStream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  final docs = snapshot.data!.docs;

                                  final timeSet = <String>{};
                                  for (var doc in docs) {
                                    final time = doc['time'];
                                    if (time != null &&
                                        time.toString().isNotEmpty) {
                                      timeSet.add(time.toString());
                                    }
                                  }

                                  final dynamicTimes = timeSet.toList()..sort();

                                  return _buildDropdown(
                                    'Time Slot (Optional)',
                                    selectedTime,
                                    dynamicTimes,
                                    (value) {
                                      setState(() {
                                        selectedTime = value;
                                      });
                                    },
                                  );
                                },
                              ),

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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: isDarkMode
                                                ? Colors.indigo[600]!
                                                : Colors.indigo,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 20,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.indigo,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Reset',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.indigo,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : showTimetable,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 4,
                                          shadowColor: Colors.indigo
                                              .withOpacity(0.3),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                        fontSize:
                                                            15, // Slightly smaller font
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),

                              // Timetable Results
                              if (timetableResult.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.indigo[800]
                                        : Colors.indigo[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: isDarkMode
                                                ? Colors.amber
                                                : Colors.indigo,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Timetable for $selectedTeacherName',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.indigo[900],
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
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.indigo[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...timetableResult
                                    .map(
                                      (lec) => Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        color: isDarkMode
                                            ? Colors.indigo[700]
                                            : Colors.white,
                                        child: ListTile(
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.indigo[600]
                                                  : Colors.indigo[100],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.school,
                                              color: isDarkMode
                                                  ? Colors.amber
                                                  : Colors.indigo,
                                            ),
                                          ),
                                          title: Text(
                                            lec['time']!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.indigo[900],
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Room: ${lec['room']}',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.indigo[700],
                                                ),
                                              ),
                                              Text(
                                                'Subject: ${lec['subject']}',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.indigo[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            color: isDarkMode
                                                ? Colors.amber
                                                : Colors.indigo,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ] else if (selectedTeacher != null &&
                                  selectedTimetableDay != null &&
                                  !isLoading) ...[
                                Container(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.schedule_send,
                                        size: 64,
                                        color: isDarkMode
                                            ? Colors.indigo[300]
                                            : Colors.indigo[200],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No classes scheduled',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.indigo[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Select different day or time slot',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white54
                                              : Colors.indigo[400],
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
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 18,
                ),
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
