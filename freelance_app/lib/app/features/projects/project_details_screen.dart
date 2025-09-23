import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

// --- Imports for Models & Services ---
import 'package:freelance_app/app/features/projects/project_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

/// A screen that displays detailed information and management options for an active project.
///
/// This screen is stateful to manage local UI state (like the stepper), but relies
/// on the central [ProposalService] via Provider for all persistent project data,
/// ensuring the UI is always in sync with the app's overall state.
class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // State for the stepper UI is managed locally within this screen.
  int _currentStep = 0;
  final List<String> _projectPhases = [
    'Research & Discovery',
    'Wireframing & Prototyping',
    'High-Fidelity UI Design',
    'Developer Handoff',
  ];

  /// Shows an AlertDialog to let the user enter an installment payment amount.
  Future<void> _showAddPaymentDialog(BuildContext context) async {
    // Use 'listen: false' as this is a one-time action within a function.
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Installment Amount (₹)', prefixText: '₹ '),
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
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
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

  /// Shows a native date picker dialog and updates the deadline via the service.
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
    // Get the completion status from the service to control the FloatingActionButton.
    // Use 'watch' to ensure this part of the UI rebuilds when the status changes.
    final isProjectComplete = context.watch<ProposalService>().allProposals.firstWhere((p) => p.id == widget.project.id).isComplete;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.align_horizontal_left_rounded), text: 'Phases'),
            ],
          ),
        ),
        floatingActionButton: isProjectComplete ? null : FloatingActionButton.extended(
          onPressed: () => _showAddPaymentDialog(context),
          label: const Text('Add Payment'),
          icon: const Icon(Icons.add_card),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildPhasesTab(context),
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
          orElse: () => Proposal(
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
              value: progress, minHeight: 10, borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text('${format.format(paid)} / ${format.format(total)} received', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Builds the "Phases" tab, which conditionally shows the stepper or the completion animation.
  Widget _buildPhasesTab(BuildContext context) {
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    final isProjectComplete = context.watch<ProposalService>().allProposals.firstWhere((p) => p.id == widget.project.id).isComplete;

    if (isProjectComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/done_animation.json', repeat: false),
              const SizedBox(height: 16),
              const Text('Project Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }
    
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (step) => setState(() => _currentStep = step),
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        final isLastStep = _currentStep == _projectPhases.length - 1;
        
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: <Widget>[
              if (isLastStep)
                ElevatedButton(
                  onPressed: () => proposalService.markProjectAsComplete(widget.project.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Done'),
                )
              else
                ElevatedButton(onPressed: details.onStepContinue, child: const Text('Continue')),

              if (_currentStep > 0)
                TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
            ],
          ),
        );
      },
      onStepContinue: () { if (_currentStep < _projectPhases.length - 1) setState(() => _currentStep += 1); },
      onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep -= 1); },
      steps: List.generate(
        _projectPhases.length,
        (index) => Step(
          title: Text(_projectPhases[index]),
          content: Container(alignment: Alignment.centerLeft, child: const Text('Details for this phase go here.')),
          isActive: _currentStep >= index,
          state: _currentStep > index ? StepState.complete : _currentStep == index ? StepState.editing : StepState.indexed,
        ),
      ),
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