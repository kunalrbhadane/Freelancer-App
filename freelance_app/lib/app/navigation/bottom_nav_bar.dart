import 'package:flutter/material.dart';

// --- Imports for all the screen destinations ---
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

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ProposalListScreen(),
    const ProjectListScreen(),
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
    // ⭐⭐⭐ STAR SERVICE: THIS IS THE NEW LOGIC ⭐⭐⭐
    // We wrap the entire Scaffold in a WillPopScope widget.
    return WillPopScope(
      // The onWillPop callback is triggered every time the user presses the back button.
      // It must return a Future<bool>.
      // - return Future.value(true)  ->  Allows the pop to happen (app will close).
      // - return Future.value(false) ->  Prevents the pop (app stays open).
      onWillPop: () async {
        // --- This is our custom logic ---
        // 1. Check if the currently selected tab is NOT the Home tab (index 0).
        if (_selectedIndex != 0) {
          // 2. If it's not the Home tab, navigate to the Home tab.
          setState(() {
            _selectedIndex = 0;
          });
          // 3. Return 'false' to PREVENT the app from closing.
          return false;
        } else {
          // 4. If we are ALREADY on the Home tab, allow the pop to happen.
          // This will close the app as expected.
          return true;
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}