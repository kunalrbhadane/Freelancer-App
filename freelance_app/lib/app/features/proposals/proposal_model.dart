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
    this.isComplete = false,
  });

  // ⭐ STAR SERVICE: NEW SERIALIZATION LOGIC STARTS HERE

  /// Converts this Proposal object into a Map that can be stored as a JSON string.
  ///
  /// We must convert complex types like [DateTime] and [ProposalStatus] into
  /// simple, storable types like String.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectTitle': projectTitle,
      'field': field,
      'offeredAmount': offeredAmount,
      // Convert DateTime to a universal string format (ISO 8601).
      'submissionDate': submissionDate.toIso8601String(),
      // Convert the Enum to its string name (e.g., 'Accepted').
      'status': status.name,
      'amountPaid': amountPaid,
      // Handle the nullable DateTime by only converting if it's not null.
      'deadline': deadline?.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  /// Creates a Proposal object from a Map (decoded from a JSON string).
  ///
  /// This factory constructor does the reverse of [toJson], carefully parsing
  /// the stored strings back into their original complex types.
  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      projectTitle: json['projectTitle'],
      field: json['field'],
      offeredAmount: json['offeredAmount'],
      // Parse the ISO 8601 string back into a DateTime object.
      submissionDate: DateTime.parse(json['submissionDate']),
      // Find the correct enum value from its string name.
      status: ProposalStatus.values.byName(json['status']),
      // Use a default value of 0.0 if the key is missing (for backward compatibility).
      amountPaid: json['amountPaid'] ?? 0.0,
      // Handle the nullable DateTime by only parsing if the value is not null.
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isComplete: json['isComplete'] ?? false,
    );
  }
}