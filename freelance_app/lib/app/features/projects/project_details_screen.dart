import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports for Models and State Management ---
import 'package:freelance_app/app/features/projects/project_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';

/// Displays the details and progress of a single active project.
///
/// This screen allows the freelancer to track the project's phases and,
/// most importantly, to mark the project as "Paid" once the work is complete
/// and payment has been received.
class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // State variable to track the current phase in the stepper
  int _currentStep = 0;

  // Static list of phases for the project stepper
  final List<String> _projectPhases = [
    'Research & Discovery',
    'Wireframing & Prototyping',
    'High-Fidelity UI Design',
    'Developer Handoff & Completion',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
        // ⭐ STAR SERVICE: The Floating Action Button is the primary action on this screen.
        // It triggers the change from a "Pending Payment" to "Received Earning".
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // 1. Get the ProposalService instance without listening for changes.
            Provider.of<ProposalService>(context, listen: false).markAsPaid(widget.project.id);
            
            // 2. Show a confirmation SnackBar to the user.
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Project marked as paid! Earnings updated.'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
            // 3. Pop the screen to return to the project list.
            Navigator.of(context).pop();
          },
          label: const Text('Mark as Paid'),
          icon: const Icon(Icons.check_circle_outline),
          backgroundColor: Colors.green,
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

  /// Builds the "Overview" tab with project details.
  Widget _buildOverviewTab(BuildContext context) {
    // We add padding to the bottom to ensure the FAB doesn't hide any content.
    return SingleChildScrollView(
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

  /// Builds the "Phases" tab with an interactive stepper for tracking progress.
  Widget _buildPhasesTab(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
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
            state: _currentStep > index ? StepState.complete :
                   _currentStep == index ? StepState.editing : StepState.indexed,
          );
        },
      ),
    );
  }

  /// Builds the "Files" tab with a mock list of project documents.
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

  // --- Reusable Helper Widgets for this Screen ---

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