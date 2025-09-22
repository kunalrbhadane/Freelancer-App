import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and numbers

// Import the model you created earlier
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

// FIX 1: Removed 'const' from the constructor
class ProposalListScreen extends StatelessWidget {
  ProposalListScreen({super.key});

  // FIX 2: Removed 'const' from the list initialization.
  final List<Proposal> proposals = [
    Proposal(
      id: 'p1',
      projectTitle: 'Flutter E-commerce App',
      offeredAmount: 3200.00,
      // FIX 3: Converted string date to a DateTime object
      submissionDate: DateTime.parse('2025-09-15'),
      status: ProposalStatus.Active,
    ),
    Proposal(
      id: 'p2',
      projectTitle: 'Brand Logo & Style Guide',
      offeredAmount: 850.00,
      submissionDate: DateTime.parse('2025-09-12'),
      status: ProposalStatus.Accepted,
    ),
    Proposal(
      id: 'p3',
      projectTitle: 'Social Media Marketing Campaign',
      offeredAmount: 1800.00,
      submissionDate: DateTime.parse('2025-09-10'),
      status: ProposalStatus.Active,
    ),
    Proposal(
      id: 'p4',
      projectTitle: 'Corporate Website Redesign',
      offeredAmount: 4500.00,
      submissionDate: DateTime.parse('2025-09-08'),
      status: ProposalStatus.Declined,
    ),
    Proposal(
      id: 'p5',
      projectTitle: 'Real Estate App UI Mockups',
      offeredAmount: 1250.00,
      submissionDate: DateTime.parse('2025-09-05'),
      status: ProposalStatus.Accepted,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the proposals for each tab
    final activeProposals =
        proposals.where((p) => p.status == ProposalStatus.Active).toList();
    final acceptedProposals =
        proposals.where((p) => p.status == ProposalStatus.Accepted).toList();
    final declinedProposals =
        proposals.where((p) => p.status == ProposalStatus.Declined).toList();

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

    // FIX 4: Simplified the date formatting. Since submissionDate is now a DateTime,
    // we no longer need to parse it here.
    final formattedDate = DateFormat('MMM d, yyyy').format(proposal.submissionDate);
    final formattedAmount =
        NumberFormat.simpleCurrency(locale: 'en_US').format(proposal.offeredAmount);

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
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle:
                      TextStyle(color: statusColor, fontWeight: FontWeight.bold),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Viewing original job posting...')),
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