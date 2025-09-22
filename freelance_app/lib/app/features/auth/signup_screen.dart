import 'package:flutter/material.dart';
// 1. Import the main app navigator
import 'package:freelance_app/app/navigation/bottom_nav_bar.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create Account,', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('Join our freelance community', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              SizedBox(height: 48),
              TextField(decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()), obscureText: true),
              SizedBox(height: 24),
              ElevatedButton(
                // 2. Add navigation to the Main App after signup
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MainNavigator()),
                  );
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: Text('SIGN UP'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    // 3. Make the "Log In" button go back
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to the previous screen
                    },
                    child: Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}