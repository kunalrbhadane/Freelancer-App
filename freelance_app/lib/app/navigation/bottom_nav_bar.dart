import 'package:flutter/material.dart';

// ⭐ STAR SERVICE: Now that the class names in their respective files are correct,
// these imports are no longer ambiguous and the app will compile successfully.
import 'package:freelance_app/app/features/dashboard/dashboard_screen.dart';
import 'package:freelance_app/app/features/proposals/proposal_list_screen.dart';
import 'package:freelance_app/app/features/projects/project_list_screen.dart';
import 'package:freelance_app/app/features/messaging/inbox_screen.dart';
import 'package:freelance_app/app/features/profile/profile_screen.dart';


class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  MainNavigatorState createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // The list of screens for each tab.
  // Both 'ProposalListScreen' and 'ProjectListScreen' are now unique classes.
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ProposalListScreen(), // Correctly points to proposal_list_screen.dart
    const ProjectListScreen(),  // Correctly points to project_list_screen.dart
    InboxScreen(),
    ProfileScreen(),
  ];

  /// Public method that allows other widgets to change the tab.
  void goToTab(int index) {
    if (index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Private method called when a user taps a navigation bar item.
  void _onItemTapped(int index) {
    goToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Proposals'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), activeIcon: Icon(Icons.mail), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}