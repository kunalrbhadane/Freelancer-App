import 'package:flutter/material.dart';
import 'package:freelance_app/app/navigation/bottom_nav_bar.dart';

// ⭐ 1. Import the bottom_nav_bar file to access its public State class.


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// This helper function finds the MainNavigator's state in the widget tree
  /// and calls the public 'goToTab' method to change the active tab.
  void _navigateToTab(BuildContext context, int index) {
    // ⭐ FIX: We now correctly reference the public 'MainNavigatorState' class.
    // This resolves the "isn't a type" error.
    final mainNavigatorState = context.findAncestorStateOfType<MainNavigatorState>();
    mainNavigatorState?.goToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications screen would open here.')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Wrap cards with GestureDetector to make them tappable.
          GestureDetector(
            onTap: () => _navigateToTab(context, 1), // Index 1 is the 'Projects' tab
            child: _buildSummaryCard(context, 'Active Projects', '3', Icons.work_outline),
          ),
          GestureDetector(
            onTap: () => _navigateToTab(context, 3), // Index 3 is the 'Inbox' tab
            child: _buildSummaryCard(context, 'New Messages', '5', Icons.mail_outline),
          ),
          // This card remains non-tappable as an example.
          _buildSummaryCard(context, 'Pending Tasks', '8', Icons.task_alt),
          const SizedBox(height: 20),
          _buildEarningsOverview(context),
        ],
      ),
    );
  }

  /// Builds a reusable summary card widget for the dashboard.
  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// Builds the earnings overview card with updated currency.
  Widget _buildEarningsOverview(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Earnings', style: TextStyle(fontSize: 16)),
                // ⭐ UI UPDATE: Currency changed to Rupees (₹)
                Text('₹1,25,000.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending Payments', style: TextStyle(fontSize: 16)),
                // ⭐ UI UPDATE: Currency changed to Rupees (₹)
                Text('₹80,000.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}