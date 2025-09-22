import 'package:flutter/material.dart';
import 'package:freelance_app/app/core/theme/app_theme.dart'; // Import your theme
import 'package:freelance_app/app/features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer App',
      // ⭐ Use the theme we created!
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}