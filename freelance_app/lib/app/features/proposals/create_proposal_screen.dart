import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// --- Imports for the Proposal Feature ---
import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/proposal_service.dart';

/// A reusable form screen for both creating new and editing existing proposals.
///
/// The screen's behavior is determined by the [proposalToEdit] parameter.
/// If null, it operates in "Create" mode with a blank form.
/// If a [Proposal] object is passed, it operates in "Edit" mode, pre-filling
/// the form with the existing data.
class CreateProposalScreen extends StatefulWidget {
  final Proposal? proposalToEdit;
  const CreateProposalScreen({super.key, this.proposalToEdit});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  // A global key for the form to handle validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;

  // A nullable String to hold the selected value from the dropdown.
  String? _selectedField;

  // A simple flag to easily check if we are in edit mode.
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    // This is the core logic that makes the form reusable.
    _isEditing = widget.proposalToEdit != null;
    final proposal = widget.proposalToEdit;

    // Initialize all controllers and the selected field value.
    // If we are in "Edit" mode, pre-fill them with data from the proposal object.
    _nameController = TextEditingController(text: _isEditing ? proposal!.projectTitle : '');
    _selectedField = _isEditing ? proposal!.field : null;
    _descriptionController = TextEditingController(text: _isEditing ? proposal!.description : '');
    _budgetController = TextEditingController(text: _isEditing ? proposal!.offeredAmount.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    // It's essential to dispose of all controllers to prevent memory leaks.
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Handles form validation and submission for both creating and updating.
  void _submitForm() {
    // Only proceed if all form fields pass their validation checks.
    if (_formKey.currentState!.validate()) {
      final proposalService = Provider.of<ProposalService>(context, listen: false);

      if (_isEditing) {
        // --- UPDATE LOGIC ---
        final oldProposal = widget.proposalToEdit!;
        final updatedProposal = Proposal(
          id: oldProposal.id,
          projectTitle: _nameController.text,
          field: _selectedField!, // The '!' is safe because the validator ensures it's not null.
          description: _descriptionController.text,
          offeredAmount: double.parse(_budgetController.text),
          // --- Preserve existing data that is not part of this form ---
          submissionDate: oldProposal.submissionDate,
          status: oldProposal.status,
          amountPaid: oldProposal.amountPaid,
          deadline: oldProposal.deadline,
          isComplete: oldProposal.isComplete,
        );
        proposalService.updateProposal(updatedProposal);
      } else {
        // --- CREATE LOGIC ---
        final newProposal = Proposal(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          projectTitle: _nameController.text,
          field: _selectedField!,
          description: _descriptionController.text,
          offeredAmount: double.parse(_budgetController.text),
          submissionDate: DateTime.now(),
          status: ProposalStatus.Active,
        );
        proposalService.addProposal(newProposal);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Proposal' : 'Create Proposal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Proposal / Project Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a name.' : null,
              ),
              const SizedBox(height: 16),

              // ⭐ STAR SERVICE: The text field for "Field of Work" has been replaced
              // with this professional DropdownButtonFormField.
              DropdownButtonFormField<String>(
                value: _selectedField,
                decoration: const InputDecoration(
                  labelText: 'Field of Work',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a category'),
                // The dropdown items are built from our "admin-editable" predefined list
                // located in the ProposalService.
                items: ProposalService.predefinedFields.map((String field) {
                  return DropdownMenuItem<String>(
                    value: field,
                    child: Text(field),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedField = newValue;
                  });
                },
                // This validator ensures the user must select an option.
                validator: (value) => value == null || value.isEmpty ? 'Please select a field.' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Project Description',
                  alignLabelWithHint: true,
                  hintText: 'Provide a brief overview of the project scope and deliverables.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a description.' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget (₹)', prefixText: '₹ ', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Enter a valid amount.' : null,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Update Proposal' : 'Save Proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}