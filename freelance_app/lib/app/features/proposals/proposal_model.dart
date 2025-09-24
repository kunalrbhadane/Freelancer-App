enum ProposalStatus { Active, Accepted, Declined }

class Proposal {
  final String id;
  final String projectTitle;
  final String field;
  // ⭐ The new, required description property.
  final String description;
  final double offeredAmount;
  final DateTime submissionDate;
  final ProposalStatus status;
  final double amountPaid;
  final DateTime? deadline;
  final bool isComplete;

  Proposal({
    required this.id,
    required this.projectTitle,
    required this.field,
    required this.description, // Add to constructor
    required this.offeredAmount,
    required this.submissionDate,
    required this.status,
    this.amountPaid = 0.0,
    this.deadline,
    this.isComplete = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectTitle': projectTitle,
      'field': field,
      'description': description, // Add to JSON
      'offeredAmount': offeredAmount,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status.name,
      'amountPaid': amountPaid,
      'deadline': deadline?.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      projectTitle: json['projectTitle'],
      field: json['field'],
      // ⭐ Read from JSON, with a fallback for older data that doesn't have this field.
      description: json['description'] ?? 'No description provided.',
      offeredAmount: json['offeredAmount'],
      submissionDate: DateTime.parse(json['submissionDate']),
      status: ProposalStatus.values.byName(json['status']),
      amountPaid: json['amountPaid'] ?? 0.0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isComplete: json['isComplete'] ?? false,
    );
  }
}