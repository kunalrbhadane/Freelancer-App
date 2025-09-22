import 'package:flutter/material.dart';

// 1. Import the login and signup screens
import 'package:freelance_app/app/features/auth/login_screen.dart';
import 'package:freelance_app/app/features/auth/signup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Your App Logo
              FlutterLogo(size: 100),
              SizedBox(height: 48),
              Text(
                'Welcome to Your Freelance Hub',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Find projects, manage your work, and get paid. All in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                // 2. Add navigation to the Sign Up screen
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text('Sign Up'),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                // 3. Add navigation to the Login screen
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Login'),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Social login buttons would have their own logic
                  IconButton(onPressed: () {}, icon: Icon(Icons.g_mobiledata)), 
                  IconButton(onPressed: () {}, icon: Icon(Icons.link)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}