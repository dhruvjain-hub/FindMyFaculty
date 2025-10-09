import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';

void main() {
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
