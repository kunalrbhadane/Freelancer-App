import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

class CreateProposalScreen extends StatefulWidget {
  const CreateProposalScreen({super.key});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fieldController = TextEditingController();
  final _budgetController = TextEditingController();

  void _submitProposal() {
    if (_formKey.currentState!.validate()) {
      final newProposal = Proposal(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        projectTitle: _nameController.text,
        field: _fieldController.text,
        offeredAmount: double.parse(_budgetController.text),
        submissionDate: DateTime.now(),
        status: ProposalStatus.Active, // New proposals are always active
      );
      // Return the new proposal object to the list screen
      Navigator.of(context).pop(newProposal);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Proposal')),
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
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a budget.';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount.';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submitProposal, child: const Text('Save Proposal')),
            ],
          ),
        ),
      ),
    );
  }
}