// lib/app/features/proposals/create_proposal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

class CreateProposalScreen extends StatefulWidget {
  final String projectTitle;

  const CreateProposalScreen({super.key, required this.projectTitle});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _coverLetterController = TextEditingController();

  void _submitProposal() {
    // Validate the form input
    if (_formKey.currentState!.validate()) {
      // Create a new Proposal object with the form data
      final newProposal = Proposal(
        id: 'p${DateTime.now().millisecondsSinceEpoch}', // Unique ID
        projectTitle: widget.projectTitle,
        offeredAmount: double.parse(_amountController.text),
        submissionDate: DateTime.now(),
        status: ProposalStatus.Active,
      );

      // Pop the screen and return the newly created proposal object
      Navigator.of(context).pop(newProposal);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.projectTitle}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your Proposal', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Your Bid Amount (₹)',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bid amount.';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _coverLetterController,
                decoration: const InputDecoration(
                  labelText: 'Cover Letter',
                  alignLabelWithHint: true, // Good for multi-line fields
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a cover letter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: _submitProposal,
                icon: const Icon(Icons.send),
                label: const Text('Submit Proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}