import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- Imports for the Proposal Feature ---
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/proposals/create_proposal_screen.dart';

/// A screen that displays and manages all of the freelancer's proposals.
///
/// This screen listens to the central [ProposalService] and automatically
/// updates its lists when proposals are added or their status changes, providing
/// a fully interactive and stateful experience.
class ProposalListScreen extends StatelessWidget {
  const ProposalListScreen({super.key});

  /// Handles opening the form screen and adding the new proposal via the service.
  Future<void> _createNewProposal(BuildContext context) async {
    final newProposal = await Navigator.of(context).push<Proposal>(
      MaterialPageRoute(builder: (context) => const CreateProposalScreen()),
    );

    if (newProposal != null) {
      // Use 'listen: false' as we are inside a function and just calling a method.
      Provider.of<ProposalService>(context, listen: false).addProposal(newProposal);
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<...> will make this widget rebuild whenever notifyListeners() is called.
    final proposalService = context.watch<ProposalService>();

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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createNewProposal(context),
          tooltip: 'Create Proposal',
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            // Each tab is built using the latest filtered list from the service.
            _buildProposalList(context, proposalService.activeProposals),
            _buildProposalList(context, proposalService.acceptedProposals),
            _buildProposalList(context, proposalService.declinedProposals),
          ],
        ),
      ),
    );
  }

  /// Builds a ListView of proposals or a placeholder message if the list is empty.
  Widget _buildProposalList(BuildContext context, List<Proposal> proposalList) {
    if (proposalList.isEmpty) {
      return Center(
        child: Text('No proposals in this category.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: proposalList.length,
      itemBuilder: (context, index) {
        // We get the service with 'listen: false' because the buttons only call
        // methods, and the parent widget is already handling the rebuilding.
        final service = Provider.of<ProposalService>(context, listen: false);
        return _buildProposalCard(context, proposalList[index], service);
      },
    );
  }

  /// Builds a single card for a proposal with context-aware action buttons.
  Widget _buildProposalCard(BuildContext context, Proposal proposal, ProposalService service) {
    final Color statusColor;
    final String statusText;
    switch (proposal.status) {
      case ProposalStatus.Active: statusColor = Colors.orange; statusText = 'Active'; break;
      case ProposalStatus.Accepted: statusColor = Colors.green; statusText = 'Accepted'; break;
      case ProposalStatus.Declined: statusColor = Colors.red; statusText = 'Declined'; break;
    }

    final formattedDate = DateFormat('MMM d, yyyy').format(proposal.submissionDate);
    final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(proposal.offeredAmount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proposal.projectTitle, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(proposal.field, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withAlpha(51),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formattedAmount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Sent: $formattedDate', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            // ⭐ STAR SERVICE: The dynamic action row is built by the helper below.
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildActionButtons(context, proposal, service),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build the correct action buttons for a given proposal status.
  Widget _buildActionButtons(BuildContext context, Proposal proposal, ProposalService service) {
    switch (proposal.status) {
      // --- Case 1: If the proposal is ACTIVE ---
      case ProposalStatus.Active:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => service.declineProposal(proposal.id),
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => service.acceptProposal(proposal.id),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Accept'),
            ),
          ],
        );

      // --- Case 2: If the proposal is ACCEPTED or DECLINED ---
      case ProposalStatus.Accepted:
      case ProposalStatus.Declined:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => service.reopenProposal(proposal.id),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Move to Active'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(120)),
              ),
            ),
          ],
        );
    }
  }
}