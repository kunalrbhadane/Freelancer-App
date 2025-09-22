import 'package:flutter/material.dart';

// --- Import all the screens that the Bottom Navigation Bar can display ---
// This import structure assumes your class names match your file names correctly.
import 'package:freelance_app/app/features/dashboard/dashboard_screen.dart';
import 'package:freelance_app/app/features/projects/project_list_screen.dart'; // Should contain 'ProjectListScreen' class
import 'package:freelance_app/app/features/proposals/proposal_list_screen.dart'; // Should contain 'ProposalListScreen' class
import 'package:freelance_app/app/features/messaging/inbox_screen.dart';
import 'package:freelance_app/app/features/profile/profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  MainNavigatorState createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // ⭐ FIX: Each screen widget is now correctly instantiated with ().
  // This resolves the 'undefined_method' error.
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ProjectListScreen(),
    const ProposalListScreen(), // Use const for stateless widgets where possible
    InboxScreen(),
    ProfileScreen(),
  ];

  /// A public method that allows other parts of the app (like the Dashboard)
  /// to programmatically change the selected tab.
  void goToTab(int index) {
    if (index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    goToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Proposals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
    );
  }
}