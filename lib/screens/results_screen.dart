// lib/screens/results_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive arguments from HomeScreen
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String day = args['day'];
    final TimeOfDay startTime = args['startTime'];
    final TimeOfDay endTime = args['endTime'];

    // Dummy teacher data
    final List<Map<String, String>> teachers = [
      {
        'name': 'Dr. Ritu Sharma',
        'subject': 'Mathematics',
        'room': 'A204',
        'location': 'Block A, 2nd Floor',
      },
      {
        'name': 'Prof. Anil Verma',
        'subject': 'Physics',
        'room': 'B102',
        'location': 'Block B, 1st Floor',
      },
      {
        'name': 'Dr. Meena Gupta',
        'subject': 'Computer Science',
        'room': 'C305',
        'location': 'Block C, 3rd Floor',
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Available Teachers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Blurred overlay for glass effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header info container
                AnimatedHeader(
                  day: day,
                  startTime: startTime.format(context),
                  endTime: endTime.format(context),
                ),

                const SizedBox(height: 20),

                // Teacher list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      return AnimatedTeacherCard(
                        index: index,
                        name: teacher['name'] ?? '',
                        subject: teacher['subject'] ?? '',
                        room: teacher['room'] ?? '',
                        location: teacher['location'] ?? '',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- ANIMATED HEADER --------------------
class AnimatedHeader extends StatelessWidget {
  final String day, startTime, endTime;
  const AnimatedHeader({
    super.key,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Day: $day",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Time: $startTime - $endTime",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_month_rounded,
                      color: Colors.deepPurpleAccent),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------- ANIMATED TEACHER CARD --------------------
class AnimatedTeacherCard extends StatefulWidget {
  final int index;
  final String name;
  final String subject;
  final String room;
  final String location;

  const AnimatedTeacherCard({
    super.key,
    required this.index,
    required this.name,
    required this.subject,
    required this.room,
    required this.location,
  });

  @override
  State<AnimatedTeacherCard> createState() => _AnimatedTeacherCardState();
}

class _AnimatedTeacherCardState extends State<AnimatedTeacherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Opening ${widget.name}'s details...")),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                child:
                    const Icon(Icons.person, color: Colors.deepPurpleAccent, size: 26),
              ),
              title: Text(
                widget.name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Subject: ${widget.subject}\nRoom: ${widget.room}\nLocation: ${widget.location}',
                  style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.deepPurpleAccent, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}