enum ProposalStatus { Active, Accepted, Declined }

class Proposal {
  final String id;
  final String projectTitle;
  final String field;
  final double offeredAmount;
  final DateTime submissionDate;
  final ProposalStatus status;
  final double amountPaid;
  final DateTime? deadline;
  
  // ⭐ STAR SERVICE: This is the new, persistent property for completion status.
  final bool isComplete;

  Proposal({
    required this.id,
    required this.projectTitle,
    required this.field,
    required this.offeredAmount,
    required this.submissionDate,
    required this.status,
    this.amountPaid = 0.0,
    this.deadline,
    // Add the new property to the constructor with a default value of 'false'.
    this.isComplete = false,
  });
}