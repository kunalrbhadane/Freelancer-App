import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Import Both of Your State Management Services ---
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/profile/profile_service.dart';

// --- Import App-level files ---
import 'package:freelance_app/app/core/theme/app_theme.dart';
import 'package:freelance_app/app/features/splash/splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ STAR SERVICE: We use MultiProvider to make multiple services available
    // to the entire application. Any screen in the widget tree below this can
    // access either ProposalService or ProfileService.
    return MultiProvider(
      providers: [
        // Provider for all proposal and project data.
        ChangeNotifierProvider(create: (context) => ProposalService()),
        // Provider for all user profile data.
        ChangeNotifierProvider(create: (context) => ProfileService()),
      ],
      // The MaterialApp is the child of MultiProvider, so all screens within it
      // can access the services defined above.
      child: MaterialApp(
        title: 'Freelancer App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}