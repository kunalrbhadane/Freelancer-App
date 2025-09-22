import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports for Models & Services ---
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/projects/project_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';

// --- Import for Navigation Destination ---
import 'package:freelance_app/app/features/projects/project_details_screen.dart';


/// A screen that displays a list of currently active projects.
/// Active projects are derived from proposals with an 'Accepted' status.
// ⭐ STAR SERVICE: The class name is now correctly set to 'ProjectListScreen'.
// This is the essential fix that resolves the 'ambiguous_import' error.
class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the ProposalService to get the list of accepted proposals.
    // This screen will automatically update if a proposal is accepted or declined.
    final acceptedProposals = context.watch<ProposalService>().acceptedProposals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Projects'),
      ),
      body: acceptedProposals.isEmpty
          ? const Center(
              child: Text(
                'You have no active projects yet.\nAccepted proposals will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: acceptedProposals.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(context, acceptedProposals[index]);
              },
            ),
    );
  }

  /// Builds a tappable card that represents an active project.
  Widget _buildProjectCard(BuildContext context, Proposal proposal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Icon(Icons.work_history, color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).primaryColor.withAlpha(40),
        ),
        title: Text(
          proposal.projectTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(proposal.field),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Adapt the accepted Proposal into a Project object to pass to the details screen.
          final projectForDetails = Project(
            id: proposal.id,
            title: proposal.projectTitle,
            description: 'This is an active project derived from your accepted proposal for "${proposal.projectTitle}".',
            budget: proposal.offeredAmount,
            deadline: 'Not set',
            requiredSkills: [],
          );
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: projectForDetails),
            ),
          );
        },
      ),
    );
  }
}