import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id;
  final String name;
  final String department;
  final String email;
  final String phone;
  final String office;
  final String qualification;
  final String experience;
  final String image;
  final List<String> subjects;
  final bool isActive;

  TeacherModel({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
    required this.phone,
    required this.office,
    required this.qualification,
    required this.experience,
    required this.image,
    required this.subjects,
    required this.isActive,
  });

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      id: doc.id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      office: data['office'] ?? '',
      qualification: data['qualification'] ?? '',
      experience: data['experience'] ?? '',
      image: data['image'] ?? '👨‍🏫',
      subjects: List<String>.from(data['subjects'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }
}
