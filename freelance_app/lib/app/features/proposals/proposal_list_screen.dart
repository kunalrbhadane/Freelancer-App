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
/// updates its lists when proposals are added, updated, or deleted, providing
/// a fully interactive and stateful experience.
class ProposalListScreen extends StatelessWidget {
  const ProposalListScreen({super.key});

  /// Handles opening the form screen in 'Create' mode.
  void _createNewProposal(BuildContext context) {
    // We are not awaiting a result anymore because the service handles the state update.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateProposalScreen()),
    );
  }

  /// Handles opening the form screen in 'Edit' mode.
  void _editProposal(BuildContext context, Proposal proposal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateProposalScreen(proposalToEdit: proposal),
      ),
    );
  }

  /// Shows a confirmation dialog before permanently deleting a proposal.
  void _showDeleteConfirmationDialog(BuildContext context, Proposal proposal, ProposalService service) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Proposal?'),
          content: Text('Are you sure you want to permanently delete the proposal for "${proposal.projectTitle}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
              onPressed: () {
                service.deleteProposal(proposal.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final proposalService = context.watch<ProposalService>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Proposals'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Active'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createNewProposal(context),
          tooltip: 'Create Proposal',
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
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
      return const Center(child: Text('No proposals in this category.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: proposalList.length,
      itemBuilder: (context, index) {
        final service = Provider.of<ProposalService>(context, listen: false);
        return _buildProposalCard(context, proposalList[index], service);
      },
    );
  }

  /// Builds a single card for a proposal with context-aware action buttons and menus.
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                // The three-dot menu is only shown for Active proposals.
                if (proposal.status == ProposalStatus.Active)
                  _buildPopupMenu(context, proposal, service)
                else
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
            // The dynamic action row is built by the helper below.
            _buildActionButtons(context, proposal, service),
          ],
        ),
      ),
    );
  }

  /// Helper to build the main action buttons at the bottom of the card.
  Widget _buildActionButtons(BuildContext context, Proposal proposal, ProposalService service) {
    switch (proposal.status) {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Accept'),
            ),
          ],
        );
      case ProposalStatus.Accepted:
      case ProposalStatus.Declined:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => service.reopenProposal(proposal.id),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Move to Active'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(120)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ],
        );
    }
  }

  /// Helper to build the three-dot popup menu for active proposals.
  Widget _buildPopupMenu(BuildContext context, Proposal proposal, ProposalService service) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _editProposal(context, proposal);
        } else if (value == 'delete') {
          _showDeleteConfirmationDialog(context, proposal, service);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit')),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete')),
        ),
      ],
    );
  }
}