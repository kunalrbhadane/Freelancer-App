// ⭐ STAR SERVICE: The error source is fixed here by defining the enum and the class property.

/// An enum to track the lifecycle of a proposal from creation to completion.
enum ProposalStatus { Active, Accepted, Declined }

/// An enum to track the payment status of an ACCEPTED proposal.
enum PaymentStatus { Unpaid, Paid }

class Proposal {
  final String id;
  final String projectTitle;
  final String field;
  final double offeredAmount;
  final DateTime submissionDate;
  final ProposalStatus status;
  // This is the property that was missing from the model definition.
  final PaymentStatus paymentStatus;

  Proposal({
    required this.id,
    required this.projectTitle,
    required this.field,
    required this.offeredAmount,
    required this.submissionDate,
    required this.status,
    // When a proposal is first created, its payment status defaults to Unpaid.
    // This makes the property required but gives it a safe default.
    this.paymentStatus = PaymentStatus.Unpaid,
  });
}