import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// --- Imports for the Proposal Feature ---
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';

/// A reusable form screen for both creating new proposals and editing existing ones.
///
/// The screen's behavior is determined by the [proposalToEdit] parameter.
/// If it's null, the screen operates in "Create" mode. Otherwise, it operates
/// in "Edit" mode, pre-filling the form with the existing data.
class CreateProposalScreen extends StatefulWidget {
  final Proposal? proposalToEdit;

  const CreateProposalScreen({super.key, this.proposalToEdit});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  // A global key for the form to handle validation.
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers to manage the input for each form field.
  late TextEditingController _nameController;
  late TextEditingController _fieldController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;

  // A simple flag to easily check if we are in edit mode.
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    // This is the core logic that makes the form reusable.
    // It checks if a proposal was passed to the screen.
    _isEditing = widget.proposalToEdit != null;
    final proposal = widget.proposalToEdit;

    // Initialize all controllers. If we are in "Edit" mode, pre-fill them
    // with the data from the proposal object passed to the screen.
    _nameController = TextEditingController(text: _isEditing ? proposal!.projectTitle : '');
    _fieldController = TextEditingController(text: _isEditing ? proposal!.field : '');
    _descriptionController = TextEditingController(text: _isEditing ? proposal!.description : '');
    _budgetController = TextEditingController(text: _isEditing ? proposal!.offeredAmount.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    // It is essential to dispose of all controllers to prevent memory leaks.
    _nameController.dispose();
    _fieldController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Handles form validation and submission for both creating and updating.
  void _submitForm() {
    // Only proceed if all form fields pass their validation checks.
    if (_formKey.currentState!.validate()) {
      // Access the ProposalService to call its methods.
      final proposalService = Provider.of<ProposalService>(context, listen: false);

      if (_isEditing) {
        // --- UPDATE LOGIC ---
        // Create an updated Proposal object using data from the form.
        final updatedProposal = Proposal(
          id: widget.proposalToEdit!.id,
          projectTitle: _nameController.text,
          field: _fieldController.text,
          description: _descriptionController.text,
          offeredAmount: double.parse(_budgetController.text),
          // --- Preserve existing data that is not part of this form ---
          submissionDate: widget.proposalToEdit!.submissionDate,
          status: widget.proposalToEdit!.status,
          amountPaid: widget.proposalToEdit!.amountPaid,
          deadline: widget.proposalToEdit!.deadline,
          isComplete: widget.proposalToEdit!.isComplete,
        );
        // Call the 'updateProposal' method in the service to save the changes.
        proposalService.updateProposal(updatedProposal);
      } else {
        // --- CREATE LOGIC ---
        // Create a brand new Proposal object with a unique ID and current date.
        final newProposal = Proposal(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          projectTitle: _nameController.text,
          field: _fieldController.text,
          description: _descriptionController.text,
          offeredAmount: double.parse(_budgetController.text),
          submissionDate: DateTime.now(),
          status: ProposalStatus.Active, // New proposals are always active by default.
        );
        // Call the 'addProposal' method in the service to save the new entry.
        proposalService.addProposal(newProposal);
      }
      // After successfully submitting, close the form screen and return to the list.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title dynamically changes based on the mode.
        title: Text(_isEditing ? 'Edit Proposal' : 'Create Proposal'),
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
                validator: (v) => v == null || v.isEmpty ? 'Please enter a name.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(labelText: 'Field of Work (e.g., Web Development)'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a field.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Project Description',
                  alignLabelWithHint: true,
                  hintText: 'Provide a brief overview of the project scope and deliverables.',
                ),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a description.' : null,
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