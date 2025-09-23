import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- Imports for Navigation and State Management ---
import 'package:freelance_app/app/navigation/bottom_nav_bar.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';

/// The main landing screen of the app, providing a dynamic overview of key metrics.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Navigates to a specific tab on the main bottom navigation bar.
  void _navigateToTab(BuildContext context, int index) {
    // Finds the public state of the MainNavigator widget to call its method
    final mainNavigatorState = context.findAncestorStateOfType<MainNavigatorState>();
    mainNavigatorState?.goToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ STAR SERVICE: By using context.watch, this widget subscribes to the
    // ProposalService. It will automatically rebuild whenever notifyListeners()
    // is called, ensuring all data displayed is live.
    final proposalService = context.watch<ProposalService>();

    // Get live counts from the service.
    final activeProjectsCount = proposalService.acceptedProposals.length;
    final activeProposalsCount = proposalService.activeProposals.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
            IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications screen would be here.')),
                    );
                },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // These summary cards are tappable and navigate to the correct tabs.
          GestureDetector(
            onTap: () => _navigateToTab(context, 2), // Index 2 is 'Projects'
            child: _buildSummaryCard(context, 'Active Projects', '$activeProjectsCount', Icons.work),
          ),
          GestureDetector(
            onTap: () => _navigateToTab(context, 1), // Index 1 is 'Proposals'
            child: _buildSummaryCard(context, 'Active Proposals', '$activeProposalsCount', Icons.description),
          ),
          const SizedBox(height: 20),
          // We pass the dynamically calculated earnings to our helper widget.
          _buildEarningsOverview(
            context,
            proposalService.totalReceivedEarnings,
            proposalService.totalPendingEarnings,
          ),
        ],
      ),
    );
  }

  /// Builds a tappable summary card for the dashboard's top section.
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

  /// Builds the dynamic earnings overview card using live data from the service.
  Widget _buildEarningsOverview(BuildContext context, double received, double pending) {
    // Use the intl package to format the numbers as Indian Rupees currency.
    final formattedReceived = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(received);
    final formattedPending = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(pending);

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Received Earnings', style: TextStyle(fontSize: 16)),
                Text(formattedReceived, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Payments', style: TextStyle(fontSize: 16)),
                Text(formattedPending, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}