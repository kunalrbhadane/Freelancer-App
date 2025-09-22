import 'package:flutter/material.dart';
import 'package:freelance_app/app/features/projects/project_list_screen.dart';

// --- Imports for Models and Navigation ---
import 'package:freelance_app/app/features/projects/project_model.dart';
import 'package:freelance_app/app/features/proposals/create_proposal_screen.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
// This import is crucial as it contains the static 'ProposalData' class.



/// A screen that displays detailed information about a single project.
///
/// This is a StatefulWidget to manage the state of the interactive stepper
/// for project phases and to handle the result of the proposal submission flow.
class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // State variable to track the current active phase in the stepper.
  int _currentStep = 0; // Start at the first step

  // Static list of phases for the project stepper UI.
  final List<String> _projectPhases = [
    'Research & Discovery',
    'Wireframing & Prototyping',
    'High-Fidelity UI Design',
    'Developer Handoff',
  ];

  /// Handles the entire "Apply for Project" workflow.
  Future<void> _applyForProject() async {
    // 1. Navigate to the CreateProposalScreen and wait for a result.
    // The `<Proposal>` type argument tells Flutter what kind of data to expect back.
    final newProposal = await Navigator.of(context).push<Proposal>(
      MaterialPageRoute(
        builder: (context) => CreateProposalScreen(projectTitle: widget.project.title),
      ),
    );

    // 2. Check if a proposal was actually submitted (and not just cancelled).
    if (newProposal != null) {
      // 3. Update the shared static list of proposals. This simulates updating a backend database.
      // We use `insert(0, ...)` to add the new proposal to the top of the list.
      setState(() {
         ProposalData.proposals.insert(0, newProposal);
      });

      // 4. Provide immediate feedback to the user with a confirmation message.
      if (mounted) { // Best practice check to ensure the widget is still in the tree
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar() // Remove any existing snackbars
            ..showSnackBar(
              const SnackBar(
                content: Text('Your proposal has been submitted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The DefaultTabController coordinates the TabBar and the TabBarView.
    return DefaultTabController(
      length: 3, // Updated to 3 tabs: Overview, Phases, Files
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.title),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.align_horizontal_left_rounded), text: 'Phases'),
              Tab(icon: Icon(Icons.folder_open), text: 'Files'),
            ],
          ),
        ),
        // A prominent, user-friendly button for the primary action on this screen.
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _applyForProject,
          label: const Text('Apply Now'),
          icon: const Icon(Icons.send),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildPhasesTab(context),
            _buildFilesTab(context),
          ],
        ),
      ),
    );
  }

  /// Builds the "Overview" tab with project description, budget, deadline, and skills.
  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      // Add padding to the bottom to ensure the FAB doesn't hide content.
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(context, 'Project Description', widget.project.description),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoChip('Deadline', widget.project.deadline)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoChip('Budget', '₹${widget.project.budget.toStringAsFixed(2)}')),
            ]
          ),
          const SizedBox(height: 16),
           _buildDetailCard(context, 'Required Skills', widget.project.requiredSkills.join(', ')),
        ],
      ),
    );
  }

  /// Builds the "Phases" tab with a modern, interactive stepper UI.
  Widget _buildPhasesTab(BuildContext context) {
    return Stepper(
      // Controls which step is currently active.
      currentStep: _currentStep,
      // Actions for the stepper controls.
      onStepTapped: (step) => setState(() => _currentStep = step),
      onStepContinue: () {
        if (_currentStep < _projectPhases.length - 1) {
          setState(() => _currentStep += 1);
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep -= 1);
        }
      },
      // Generates the steps dynamically from the `_projectPhases` list.
      steps: List.generate(
        _projectPhases.length,
        (index) {
          return Step(
            title: Text(_projectPhases[index]),
            content: Container(
              alignment: Alignment.centerLeft,
              child: const Text('Details and deliverables for this phase go here.'),
            ),
            isActive: _currentStep >= index,
            // Visually indicates progress: completed, current, or upcoming.
            state: _currentStep > index ? StepState.complete :
                   _currentStep == index ? StepState.editing : StepState.indexed,
          );
        },
      ),
    );
  }

  /// Builds the "Files" tab with a simple list of project-related documents.
  Widget _buildFilesTab(BuildContext context) {
    return ListView(
      children: [
        ListTile(
            leading: const Icon(Icons.picture_as_pdf, size: 40),
            title: const Text('project-brief.pdf'),
            trailing: const Icon(Icons.download_for_offline_outlined),
            onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading file... (mock)')));
            },
          ),
        ListTile(
            leading: const Icon(Icons.folder_zip, size: 40),
            title: const Text('brand-assets.zip'),
            trailing: const Icon(Icons.download_for_offline_outlined),
            onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading file... (mock)')));
            },
          ),
      ],
    );
  }

  // --- Reusable Helper Widgets ---

  Widget _buildDetailCard(BuildContext context, String title, String content) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
      Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
    ]))
  );

  Widget _buildInfoChip(String label, String value) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Text(label, style: TextStyle(color: Colors.grey[600])), const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ])),
  );
}