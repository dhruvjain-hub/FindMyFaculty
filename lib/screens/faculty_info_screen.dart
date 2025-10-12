import 'package:flutter/material.dart';

class FacultyInfoScreen extends StatefulWidget {
  final bool isDarkMode;

  const FacultyInfoScreen({super.key, required this.isDarkMode});

  @override
  State<FacultyInfoScreen> createState() => _FacultyInfoScreenState();
}

class _FacultyInfoScreenState extends State<FacultyInfoScreen> {
  // Sample faculty data
  final List<Map<String, dynamic>> facultyList = [
    {
      'name': 'Dr. Rajesh Sharma',
      'department': 'Computer Science',
      'email': 'rajesh.sharma@university.edu',
      'phone': '+91 9876543210',
      'office': 'Block A, Room 101',
      'subjects': ['Data Structures', 'Algorithms', 'Machine Learning'],
      'qualification': 'Ph.D. in Computer Science',
      'experience': '15 years',
      'image': '👨‍🏫',
    },
    {
      'name': 'Prof. Priya Gupta',
      'department': 'Mathematics',
      'email': 'priya.gupta@university.edu',
      'phone': '+91 9876543211',
      'office': 'Block B, Room 205',
      'subjects': ['Calculus', 'Linear Algebra', 'Statistics'],
      'qualification': 'M.Sc., Ph.D. in Mathematics',
      'experience': '12 years',
      'image': '👩‍🏫',
    },
    {
      'name': 'Dr. Amit Kumar',
      'department': 'Physics',
      'email': 'amit.kumar@university.edu',
      'phone': '+91 9876543212',
      'office': 'Block C, Room 150',
      'subjects': ['Quantum Mechanics', 'Thermodynamics', 'Optics'],
      'qualification': 'Ph.D. in Physics',
      'experience': '18 years',
      'image': '👨‍🔬',
    },
    {
      'name': 'Prof. Sunita Patel',
      'department': 'Chemistry',
      'email': 'sunita.patel@university.edu',
      'phone': '+91 9876543213',
      'office': 'Block D, Room 320',
      'subjects': ['Organic Chemistry', 'Analytical Chemistry', 'Biochemistry'],
      'qualification': 'Ph.D. in Chemistry',
      'experience': '14 years',
      'image': '👩‍🔬',
    },
    {
      'name': 'Dr. Vikram Singh',
      'department': 'Electronics',
      'email': 'vikram.singh@university.edu',
      'phone': '+91 9876543214',
      'office': 'Block E, Room 415',
      'subjects': ['Digital Electronics', 'Microprocessors', 'VLSI Design'],
      'qualification': 'Ph.D. in Electronics',
      'experience': '16 years',
      'image': '👨‍💻',
    },
  ];

  String searchQuery = '';
  String selectedDepartment = 'All';
  List<String> departments = ['All', 'Computer Science', 'Mathematics', 'Physics', 'Chemistry', 'Electronics'];

  List<Map<String, dynamic>> get filteredFaculty {
    return facultyList.where((faculty) {
      final matchesSearch = faculty['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          faculty['department'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesDepartment = selectedDepartment == 'All' || faculty['department'] == selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();
  }

  void _showFacultyDetails(Map<String, dynamic> faculty) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.indigo[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? Colors.indigo[700] : Colors.indigo[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            faculty['image'],
                            style: const TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        faculty['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.indigo[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? Colors.indigo[700] : Colors.indigo[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          faculty['department'],
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Contact Information
                _buildInfoSection(
                  icon: Icons.contact_mail,
                  title: 'Contact Information',
                  children: [
                    _buildInfoItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: faculty['email'],
                    ),
                    _buildInfoItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: faculty['phone'],
                    ),
                    _buildInfoItem(
                      icon: Icons.location_on,
                      label: 'Office',
                      value: faculty['office'],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Professional Details
                _buildInfoSection(
                  icon: Icons.school,
                  title: 'Professional Details',
                  children: [
                    _buildInfoItem(
                      icon: Icons.workspace_premium,
                      label: 'Qualification',
                      value: faculty['qualification'],
                    ),
                    _buildInfoItem(
                      icon: Icons.work_history,
                      label: 'Experience',
                      value: faculty['experience'],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Subjects Taught
                _buildInfoSection(
                  icon: Icons.menu_book,
                  title: 'Subjects Taught',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: faculty['subjects'].map<Widget>((subject) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: widget.isDarkMode ? Colors.indigo[600]! : Colors.indigo[200]!,
                            ),
                          ),
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white70 : Colors.indigo[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Email action
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: widget.isDarkMode ? Colors.indigo[600]! : Colors.indigo,
                          ),
                        ),
                        icon: Icon(
                          Icons.email,
                          color: widget.isDarkMode ? Colors.white : Colors.indigo,
                        ),
                        label: Text(
                          'Email',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Call action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text(
                          'Call',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: widget.isDarkMode ? Colors.amber : Colors.indigo,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.indigo[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: widget.isDarkMode ? Colors.amber : Colors.indigo,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDarkMode ? Colors.white70 : Colors.indigo[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.white : Colors.indigo[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.indigo[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.indigo[800] : Colors.indigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Faculty Information',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.indigo[900]!, Colors.purple[900]!]
                : [Colors.indigo[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.indigo[800] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search faculty by name or department...',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode ? Colors.white60 : Colors.indigo[400],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.indigo[900],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Department Filter
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final department = departments[index];
                        final isSelected = department == selectedDepartment;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              department,
                              style: TextStyle(
                                color: isSelected
                                    ? (widget.isDarkMode ? Colors.indigo[900] : Colors.white)
                                    : (widget.isDarkMode ? Colors.white : Colors.indigo),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedDepartment = department;
                              });
                            },
                            backgroundColor: widget.isDarkMode ? Colors.indigo[800] : Colors.indigo[50],
                            selectedColor: widget.isDarkMode ? Colors.amber : Colors.indigo,
                            checkmarkColor: widget.isDarkMode ? Colors.indigo[900] : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Faculty Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${filteredFaculty.length} Faculty Members',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.indigo[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Faculty List
            Expanded(
              child: filteredFaculty.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: widget.isDarkMode ? Colors.indigo[300] : Colors.indigo[200],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No faculty found',
                            style: TextStyle(
                              fontSize: 18,
                              color: widget.isDarkMode ? Colors.white70 : Colors.indigo[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing your search or filter',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white54 : Colors.indigo[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredFaculty.length,
                      itemBuilder: (context, index) {
                        final faculty = filteredFaculty[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          color: widget.isDarkMode ? Colors.indigo[800] : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: widget.isDarkMode ? Colors.indigo[700] : Colors.indigo[100],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  faculty['image'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(
                              faculty['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.isDarkMode ? Colors.white : Colors.indigo[900],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode ? Colors.indigo[700] : Colors.indigo[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    faculty['department'],
                                    style: TextStyle(
                                      color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  faculty['qualification'],
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white70 : Colors.indigo[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: widget.isDarkMode ? Colors.amber : Colors.indigo,
                              size: 16,
                            ),
                            onTap: () => _showFacultyDetails(faculty),
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