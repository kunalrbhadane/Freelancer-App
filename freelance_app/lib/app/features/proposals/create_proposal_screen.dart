import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';
import 'package:provider/provider.dart';

/// A reusable form screen for both creating new and editing existing proposals.
///
/// The screen's behavior is determined by the [proposalToEdit] parameter.
/// - If [proposalToEdit] is null, it operates in "Create" mode.
/// - If a [Proposal] object is passed, it operates in "Edit" mode, pre-filling
///   the form with the existing data.
class CreateProposalScreen extends StatefulWidget {
  // ⭐ STAR SERVICE: The optional parameter that makes this form reusable.
  final Proposal? proposalToEdit;

  const CreateProposalScreen({super.key, this.proposalToEdit});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  // Declare the text controllers that will hold the form's data.
  late TextEditingController _nameController;
  late TextEditingController _fieldController;
  late TextEditingController _budgetController;

  // A simple flag to easily check if we are in edit mode.
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    // Determine the mode based on the passed parameter.
    _isEditing = widget.proposalToEdit != null;

    // Initialize the controllers.
    _nameController = TextEditingController();
    _fieldController = TextEditingController();
    _budgetController = TextEditingController();

    // ⭐ STAR SERVICE: If we are in "Edit" mode, this is the crucial logic
    // that pre-fills the text fields with the data from the proposal.
    if (_isEditing) {
      final proposal = widget.proposalToEdit!;
      _nameController.text = proposal.projectTitle;
      _fieldController.text = proposal.field;
      _budgetController.text = proposal.offeredAmount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    // It is essential to dispose of controllers to prevent memory leaks.
    _nameController.dispose();
    _fieldController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Handles the form submission for both creating and updating.
  void _submitForm() {
    // First, validate the form to ensure all fields are correctly filled.
    if (_formKey.currentState!.validate()) {
      // Get the ProposalService to call its methods. listen: false is used
      // because we are in a function, not in the build method.
      final proposalService = Provider.of<ProposalService>(context, listen: false);

      // ⭐ STAR SERVICE: This is the core conditional logic.
      if (_isEditing) {
        // --- UPDATE LOGIC ---
        // Create an updated Proposal object, making sure to preserve immutable data
        // like the original ID and submission date.
        final updatedProposal = Proposal(
          id: widget.proposalToEdit!.id,
          projectTitle: _nameController.text,
          field: _fieldController.text,
          offeredAmount: double.parse(_budgetController.text),
          // Preserve the original data that shouldn't be changed by the edit form.
          submissionDate: widget.proposalToEdit!.submissionDate,
          status: widget.proposalToEdit!.status,
          amountPaid: widget.proposalToEdit!.amountPaid,
          deadline: widget.proposalToEdit!.deadline,
          isComplete: widget.proposalToEdit!.isComplete,
        );
        // Call the service method to update the central state.
        proposalService.updateProposal(updatedProposal);
      } 
      else {
        // --- CREATE LOGIC ---
        // Create a brand new Proposal object with a new ID and current date.
        final newProposal = Proposal(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          projectTitle: _nameController.text,
          field: _fieldController.text,
          offeredAmount: double.parse(_budgetController.text),
          submissionDate: DateTime.now(),
          status: ProposalStatus.Active, // New proposals are always active.
        );
        // Call the service method to add the new proposal to the central state.
        proposalService.addProposal(newProposal);
      }
      // After successfully submitting, close the form screen.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title dynamically changes based on whether we are editing or creating.
        title: Text(_isEditing ? 'Edit Proposal' : 'Create New Proposal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Proposal / Project Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(labelText: 'Field of Work (e.g., Web Development)'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a field.' : null,

              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget (₹)', prefixText: '₹ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Enter a valid amount.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                // The button text also dynamically changes.
                child: Text(_isEditing ? 'Update Proposal' : 'Save Proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}