import 'package:flutter/material.dart';
import 'package:freelance_app/app/core/theme/app_theme.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/splash/splash_screen.dart';
import 'package:provider/provider.dart'; // <-- Import provider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ STAR SERVICE: We wrap the entire app in a ChangeNotifierProvider.
    // This creates one instance of our ProposalService and makes it available
    // to any screen down the widget tree.
    return ChangeNotifierProvider(
      create: (context) => ProposalService(),
      child: MaterialApp(
        title: 'Freelancer App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}