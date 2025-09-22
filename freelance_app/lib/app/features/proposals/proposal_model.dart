// lib/app/features/proposals/proposal_model.dart

enum ProposalStatus { Active, Accepted, Declined }

class Proposal {
  final String id;
  final String projectTitle;
  final double offeredAmount;
  final DateTime submissionDate; // This must be a DateTime
  final ProposalStatus status;

  // The constructor is not 'const' because it handles dynamic data
  Proposal({
    required this.id,
    required this.projectTitle,
    required this.offeredAmount,
    required this.submissionDate,
    required this.status,
  });
}