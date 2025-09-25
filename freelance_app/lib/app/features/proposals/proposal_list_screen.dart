import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- Imports for the Proposal Feature ---
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/proposals/create_proposal_screen.dart';
import 'package:freelance_app/app/features/proposals/sort_option_model.dart';

/// The main screen for viewing and managing all proposals.
///
/// This screen is a [StatefulWidget] to manage the lifecycle of the search
/// controller. It connects to the [ProposalService] using Provider to display
/// live data and provides UI for creating, editing, deleting, filtering,
/// searching, and sorting proposals.
class ProposalListScreen extends StatefulWidget {
  const ProposalListScreen({super.key});

  @override
  State<ProposalListScreen> createState() => _ProposalListScreenState();
}

class _ProposalListScreenState extends State<ProposalListScreen> {
  // A controller to manage the text in the search bar.
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add a listener to the search controller. Every time the text changes,
    // it will call the search method in our service, triggering a UI update.
    _searchController.addListener(() {
      Provider.of<ProposalService>(context, listen: false).search(_searchController.text);
    });
  }

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks.
    _searchController.dispose();
    super.dispose();
  }

  // --- Navigation & Dialog Helper Methods ---

  void _createNewProposal() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateProposalScreen()),
    );
  }

  void _editProposal(Proposal proposal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CreateProposalScreen(proposalToEdit: proposal)),
    );
  }

  void _showDeleteConfirmationDialog(Proposal proposal, ProposalService service) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Proposal?'),
        content: Text('Are you sure you want to permanently delete the proposal for "${proposal.projectTitle}"?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
            onPressed: () {
              service.deleteProposal(proposal.id);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
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
            Tab(text: 'Active'), Tab(text: 'Accepted'), Tab(text: 'Declined'),
          ]),
          actions: [_buildSortMenu(proposalService), const SizedBox(width: 8)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewProposal,
          tooltip: 'Create Proposal',
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 8),
                  _buildFilterChips(proposalService),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProposalList(proposalService.activeProposals),
                  _buildProposalList(proposalService.acceptedProposals),
                  _buildProposalList(proposalService.declinedProposals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Building Helper Widgets ---

  Widget _buildSortMenu(ProposalService service) {
    return PopupMenuButton<SortOption>(
      onSelected: (SortOption selectedOrder) => service.setSortOrder(selectedOrder),
      icon: const Icon(Icons.sort),
      tooltip: 'Sort Proposals',
      itemBuilder: (BuildContext context) {
        final currentOrder = service.currentSortOrder;
        return [
          PopupMenuItem<SortOption>(value: SortOption.newestFirst, child: _buildSortMenuItem('Newest First', currentOrder == SortOption.newestFirst)),
          PopupMenuItem<SortOption>(value: SortOption.highestBudget, child: _buildSortMenuItem('Highest Budget', currentOrder == SortOption.highestBudget)),
          PopupMenuItem<SortOption>(value: SortOption.byDeadline, child: _buildSortMenuItem('By Deadline (soonest)', currentOrder == SortOption.byDeadline)),
        ];
      },
    );
  }

  Widget _buildSortMenuItem(String text, bool isSelected) {
    return Row(
      children: [
        Expanded(child: Text(text)),
        if (isSelected) Icon(Icons.check, color: Theme.of(context).primaryColor),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by project title...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
        filled: true,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFilterChips(ProposalService service) {
    final fields = ProposalService.predefinedFields;
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          return FilterChip(
            label: Text(field),
            selected: service.isActiveFilter(field),
            onSelected: (_) => service.toggleFilter(field),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildProposalList(List<Proposal> proposalList) {
    if (proposalList.isEmpty) {
      final hasActiveFilter = Provider.of<ProposalService>(context, listen: false).hasActiveFilterOrSearch;
      return Center(child: Text(hasActiveFilter ? 'No proposals match your search/filter.' : 'No proposals in this category.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: proposalList.length,
      itemBuilder: (context, index) {
        final service = Provider.of<ProposalService>(context, listen: false);
        return _buildProposalCard(proposalList[index], service);
      },
    );
  }

  Widget _buildProposalCard(Proposal proposal, ProposalService service) {
    final formattedDate = DateFormat('MMM d, yyyy').format(proposal.submissionDate);
    final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(proposal.offeredAmount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proposal.projectTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(proposal.field, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (proposal.status == ProposalStatus.Active) _buildPopupMenu(proposal, service)
                else _buildStatusChip(context, proposal),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formattedAmount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Sent: $formattedDate', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            _buildActionButtons(proposal, service),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(Proposal proposal, ProposalService service) {
    switch (proposal.status) {
      case ProposalStatus.Active:
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => service.declineProposal(proposal.id),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Decline'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => service.acceptProposal(proposal.id),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              child: const Text('Accept'),
            ),
          ]),
        );
      case ProposalStatus.Accepted:
      case ProposalStatus.Declined:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OutlinedButton.icon(
                onPressed: () => service.reopenProposal(proposal.id),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Move to Active'),
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor, side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(120)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPopupMenu(Proposal proposal, ProposalService service) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') _editProposal(proposal);
        if (value == 'delete') _showDeleteConfirmationDialog(proposal, service);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
      ],
    );
  }
  
  Widget _buildStatusChip(BuildContext context, Proposal proposal) {
    final statusColor = proposal.status == ProposalStatus.Accepted ? Colors.green : Colors.red;
    final statusText = proposal.status.name;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Chip(
        label: Text(statusText),
        backgroundColor: statusColor.withAlpha(51),
        labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}