import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

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
  // Local state for the stepper UI
  int _currentStep = 0;
  final List<String> _projectPhases = [
    'Research & Discovery',
    'Wireframing & Prototyping',
    'High-Fidelity UI Design',
    'Developer Handoff',
  ];

  Future<void> _showAddPaymentDialog(BuildContext context, {required double pendingAmount}) async {
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    amountController.text = pendingAmount > 0 ? pendingAmount.toStringAsFixed(2) : '';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pendingAmount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Pending: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(pendingAmount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Installment Amount (₹)', prefixText: '₹ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Enter a valid amount.' : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  proposalService.addPayment(widget.project.id, double.parse(amountController.text));
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

  Future<void> _selectDeadline(BuildContext context) async {
    final proposalService = Provider.of<ProposalService>(context, listen: false);
    final currentProposal = proposalService.allProposals.firstWhere((p) => p.id == widget.project.id);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentProposal.deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (pickedDate != null && mounted) {
      proposalService.setDeadline(widget.project.id, pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ STAR SERVICE: This is the corrected 'firstWhere' call.
    // In the unlikely event a project doesn't exist, we provide a safe, empty fallback.
    final fullProposal = context.watch<ProposalService>().allProposals.firstWhere(
          (p) => p.id == widget.project.id,
          orElse: () => Proposal(
              id: widget.project.id, projectTitle: widget.project.title, field: 'N/A', description: 'Project not found.',
              offeredAmount: 0, submissionDate: DateTime.now(), status: ProposalStatus.Declined
          ),
        );
    final isProjectComplete = fullProposal.isComplete;
    final pendingAmount = fullProposal.offeredAmount - fullProposal.amountPaid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.title),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
            Tab(icon: Icon(Icons.align_horizontal_left_rounded), text: 'Phases'),
          ]),
        ),
        floatingActionButton: isProjectComplete ? null : FloatingActionButton.extended(
          onPressed: () => _showAddPaymentDialog(context, pendingAmount: pendingAmount),
          label: const Text('Add Payment'),
          icon: const Icon(Icons.add_card),
        ),
        body: TabBarView(
          children: [_buildOverviewTab(context), _buildPhasesTab(context)],
        ),
      ),
    );
  }

  Widget _buildPhasesTab(BuildContext context) {
    final proposalService = context.watch<ProposalService>();
    final fullProposal = proposalService.allProposals.firstWhere((p) => p.id == widget.project.id);
    
    if (fullProposal.isComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Lottie.asset('assets/animations/done_animation.json', repeat: false),
            const SizedBox(height: 16),
            const Text('Project Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
        ),
      );
    }

    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (step) => setState(() => _currentStep = step),
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        final isLastStep = _currentStep == _projectPhases.length - 1;
        if (!isLastStep) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(children: [
              ElevatedButton(onPressed: details.onStepContinue, child: const Text('Continue')),
              if (_currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
            ]),
          );
        } else {
          final isFullyPaid = fullProposal.amountPaid >= fullProposal.offeredAmount;
          if (isFullyPaid) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(children: [
                ElevatedButton(
                  onPressed: () => proposalService.markProjectAsComplete(widget.project.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Done'),
                ),
                TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
              ]),
            );
          } else {
            final pendingAmount = fullProposal.offeredAmount - fullProposal.amountPaid;
            final formattedPending = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(pendingAmount);
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment Pending: $formattedPending', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(
                    onPressed: () => _showAddPaymentDialog(context, pendingAmount: pendingAmount),
                    child: const Text('Add Payment'),
                  ),
                  TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                ]),
              ]),
            );
          }
        }
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

  Widget _buildOverviewTab(BuildContext context) {
    final fullProposal = context.watch<ProposalService>().allProposals.firstWhere(
          (p) => p.id == widget.project.id,
          orElse: () => Proposal(
              id: widget.project.id, projectTitle: widget.project.title, field: 'N/A', description: 'Project not found.',
              offeredAmount: widget.project.budget, submissionDate: DateTime.now(), status: ProposalStatus.Declined
          ),
        );
    final deadlineText = fullProposal.deadline != null ? DateFormat('MMM d, yyyy').format(fullProposal.deadline!) : 'Tap to set';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentStatusCard(context, fullProposal.amountPaid, fullProposal.offeredAmount),
          const SizedBox(height: 16),
          // ⭐ This now correctly uses the user-entered description from the Proposal object.
          _buildDetailCard(context, 'Project Description', fullProposal.description),
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

  Widget _buildDetailCard(BuildContext context, String title, String content) => Card(
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