import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- Imports for Models & Services ---
import 'package:freelance_app/app/features/projects/project_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // State variable to manage the current step in the 'Phases' tab stepper.
  int _currentStep = 0;

  // Static list of phases for the stepper UI.
  final List<String> _projectPhases = [
    'Research & Discovery',
    'Wireframing & Prototyping',
    'High-Fidelity UI Design',
    'Developer Handoff',
  ];

  /// Shows an AlertDialog to let the user enter an installment payment amount.
  Future<void> _showAddPaymentDialog(BuildContext context) async {
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss.
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Installment Amount (₹)',
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an amount.';
                if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Enter a valid positive amount.';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  proposalService.addPayment(widget.project.id, amount);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a native date picker dialog and updates the state via the service.
  Future<void> _selectDeadline(BuildContext context) async {
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    
    final currentProposal = proposalService.allProposals.firstWhere((p) => p.id == widget.project.id);
    final currentDeadline = currentProposal.deadline;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null && mounted) {
      proposalService.setDeadline(widget.project.id, pickedDate);
    }
  }

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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddPaymentDialog(context),
          label: const Text('Add Payment'),
          icon: const Icon(Icons.add_card),
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

  // --- UI Building Helper Widgets ---

  /// Builds the "Overview" tab. It watches the service for live payment/deadline updates.
  Widget _buildOverviewTab(BuildContext context) {
    final fullProposal = context.watch<ProposalService>().allProposals.firstWhere(
          (p) => p.id == widget.project.id,
          orElse: () => Proposal( // Failsafe default object
            id: widget.project.id, projectTitle: widget.project.title,
            field: 'N/A', offeredAmount: widget.project.budget,
            submissionDate: DateTime.now(), status: ProposalStatus.Accepted,
          ),
        );
    
    final deadlineText = fullProposal.deadline != null
        ? DateFormat('MMM d, yyyy').format(fullProposal.deadline!)
        : 'Tap to set';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentStatusCard(context, fullProposal.amountPaid, fullProposal.offeredAmount),
          const SizedBox(height: 16),
          _buildDetailCard(context, 'Project Description', widget.project.description),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoChip('Deadline', deadlineText, icon: Icons.calendar_today)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoChip('Budget', '₹${fullProposal.offeredAmount.toStringAsFixed(2)}')),
            ],
          ),
          if (widget.project.requiredSkills.isNotEmpty) const SizedBox(height: 16),
          if (widget.project.requiredSkills.isNotEmpty)
            _buildDetailCard(context, 'Required Skills', widget.project.requiredSkills.join(', ')),
        ],
      ),
    );
  }

  /// Builds a card to visually represent the payment progress of a project.
  Widget _buildPaymentStatusCard(BuildContext context, double paid, double total) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final progress = total > 0 ? paid / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${format.format(paid)} / ${format.format(total)} received',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Phases" tab with an interactive stepper for tracking progress.
  Widget _buildPhasesTab(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (step) => setState(() => _currentStep = step),
      onStepContinue: () {
        if (_currentStep < _projectPhases.length - 1) setState(() => _currentStep += 1);
      },
      onStepCancel: () {
        if (_currentStep > 0) setState(() => _currentStep -= 1);
      },
      steps: List.generate(
        _projectPhases.length,
        (index) => Step(
          title: Text(_projectPhases[index]),
          content: Container(
            alignment: Alignment.centerLeft,
            child: const Text('Details and deliverables for this phase go here.'),
          ),
          isActive: _currentStep >= index,
          state: _currentStep > index ? StepState.complete
              : _currentStep == index ? StepState.editing
              : StepState.indexed,
        ),
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
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading file... (mock)')),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.folder_zip, size: 40),
          title: const Text('brand-assets.zip'),
          trailing: const Icon(Icons.download_for_offline_outlined),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloading file... (mock)')),
          ),
        ),
      ],
    );
  }

  /// Reusable helper for generic detail cards.
  Widget _buildDetailCard(BuildContext context, String title, String content) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
            ],
          ),
        ),
      );

  /// Reusable helper for small info chips with optional icons.
  Widget _buildInfoChip(String label, String value, {IconData? icon}) {
    // Determine if the chip should be tappable based on whether an icon is provided
    final isTappable = icon != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isTappable ? () => _selectDeadline(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isTappable) Icon(icon, color: Colors.grey[600], size: 20),
              if (isTappable) const SizedBox(width: 8),
              Flexible(
                child: Column(
                  children: [
                    Text(label, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}