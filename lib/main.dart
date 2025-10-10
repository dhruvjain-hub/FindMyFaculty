import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before app runs
  runApp(const FindMyFacultyApp());
}

class FindMyFacultyApp extends StatelessWidget {
  const FindMyFacultyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find My Faculty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Use system theme
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),   // Splash shown first
        '/home': (context) => const HomeScreen(), // Home screen after splash
        '/results': (context) => const ResultsScreen(), // Result screen
      },
    );
  }
}
