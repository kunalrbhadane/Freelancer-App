import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:freelance_app/app/features/proposals/proposal_model.dart';

// ⭐ 1. A dedicated class to hold our shared, static "database" of proposals.
// Any part of the app can now access and modify this list. This allows the
// ProjectDetailsScreen to add new proposals and have them appear here.
class ProposalData {
  static List<Proposal> proposals = [
    Proposal(
      id: 'p5',
      projectTitle: 'Real Estate App UI Mockups',
      offeredAmount: 1250.00,
      submissionDate: DateTime(2025, 9, 5),
      status: ProposalStatus.Accepted,
    ),
    Proposal(
      id: 'p2',
      projectTitle: 'Brand Logo & Style Guide',
      offeredAmount: 850.00,
      submissionDate: DateTime(2025, 9, 12),
      status: ProposalStatus.Accepted,
    ),
    Proposal(
      id: 'p4',
      projectTitle: 'Corporate Website Redesign',
      offeredAmount: 4500.00,
      submissionDate: DateTime(2025, 9, 8),
      status: ProposalStatus.Declined,
    ),
  ];
}


// ⭐ 2. The screen is now a StatefulWidget. This ensures that it rebuilds
// with the latest data from `ProposalData` whenever the user views it.
class ProposalListScreen extends StatefulWidget {
  const ProposalListScreen({super.key});

  @override
  State<ProposalListScreen> createState() => _ProposalListScreenState();
}

class _ProposalListScreenState extends State<ProposalListScreen> {

  @override
  Widget build(BuildContext context) {
    // Filter the proposals from our static data source FOR EACH BUILD.
    // This ensures that any time the user visits this tab, it has the latest data.
    final allProposals = ProposalData.proposals;
    final activeProposals = allProposals.where((p) => p.status == ProposalStatus.Active).toList();
    final acceptedProposals = allProposals.where((p) => p.status == ProposalStatus.Accepted).toList();
    final declinedProposals = allProposals.where((p) => p.status == ProposalStatus.Declined).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Proposals'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Accepted'),
              Tab(text: 'Declined'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProposalList(context, activeProposals, 'Active'),
            _buildProposalList(context, acceptedProposals, 'Accepted'),
            _buildProposalList(context, declinedProposals, 'Declined'),
          ],
        ),
      ),
    );
  }

  /// Builds a list of proposals or a placeholder message if the list is empty.
  Widget _buildProposalList(BuildContext context, List<Proposal> proposalList, String status) {
    if (proposalList.isEmpty) {
      return Center(
        child: Text(
          'No $status proposals.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: proposalList.length,
      itemBuilder: (context, index) {
        // Sort proposals by date, showing the newest first.
        proposalList.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
        final proposal = proposalList[index];
        return _buildProposalCard(context, proposal);
      },
    );
  }

  /// Builds a single card widget to display proposal information.
  Widget _buildProposalCard(BuildContext context, Proposal proposal) {
    // Determine status color and text
    final Color statusColor;
    final String statusText;
    switch (proposal.status) {
      case ProposalStatus.Active:
        statusColor = Colors.orange;
        statusText = 'Active';
        break;
      case ProposalStatus.Accepted:
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case ProposalStatus.Declined:
        statusColor = Colors.red;
        statusText = 'Declined';
        break;
    }

    final formattedDate = DateFormat('MMM d, yyyy').format(proposal.submissionDate);
    // Use the Indian Rupee symbol and formatting
    final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(proposal.offeredAmount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    proposal.projectTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(statusText),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: statusColor.withOpacity(0.15),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted on: $formattedDate',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Offer: $formattedAmount',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Viewing original job posting... (mock)')),
                    );
                  },
                  child: const Text('View Job'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}