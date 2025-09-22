enum ProposalStatus { Active, Accepted, Declined }
enum PaymentStatus { Unpaid, Paid }

class Proposal {
  final String id;
  final String projectTitle;
  final String field;
  final double offeredAmount;
  final DateTime submissionDate;
  final ProposalStatus status;

  // ⭐ STAR SERVICE: This is the correctly named and defined property that was missing.
  final double amountPaid;
  final DateTime? deadline;

  Proposal({
    required this.id,
    required this.projectTitle,
    required this.field,
    required this.offeredAmount,
    required this.submissionDate,
    required this.status,
    // Add amountPaid to the constructor with a default value.
    this.amountPaid = 0.0,
    this.deadline,
  });
}