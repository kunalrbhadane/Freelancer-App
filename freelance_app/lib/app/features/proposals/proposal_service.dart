import 'package:flutter/foundation.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

/// The central state management service for all proposal and project-related data.
///
/// This class extends [ChangeNotifier], allowing UI widgets that listen to it
/// (using Provider) to automatically update when the underlying data changes.
/// It acts as the single source of truth for the entire app.
class ProposalService extends ChangeNotifier {
  // --- Private State Data (The "Mock Database") ---
  final List<Proposal> _proposals = [
    Proposal(
      id: 'p1',
      projectTitle: 'Brand Logo & Style Guide',
      field: 'Graphic Design',
      offeredAmount: 85000.00,
      submissionDate: DateTime.parse('2025-09-12'),
      status: ProposalStatus.Accepted,
      amountPaid: 85000.00,
      deadline: DateTime.parse('2025-10-15'),
      isComplete: true, // This completed project is also fully paid
    ),
    Proposal(
      id: 'p2',
      projectTitle: 'Fitness Tracker App UI/UX',
      field: 'Mobile App Design',
      offeredAmount: 220000.00,
      submissionDate: DateTime.parse('2025-09-15'),
      status: ProposalStatus.Accepted,
      amountPaid: 50000.00, // This project is ongoing with a partial payment
    ),
    Proposal(
      id: 'p3',
      projectTitle: 'Social Media Marketing',
      field: 'Marketing',
      offeredAmount: 180000.00,
      submissionDate: DateTime.parse('2025-09-10'),
      status: ProposalStatus.Active, // This proposal is waiting for a response
    ),
  ];

  // --- Public Getters (Safe, read-only access to the state) ---

  /// Returns the complete list of all proposals.
  List<Proposal> get allProposals => _proposals;

  /// Returns a filtered list of proposals with 'Active' status.
  List<Proposal> get activeProposals => _proposals.where((p) => p.status == ProposalStatus.Active).toList();

  /// Returns a filtered list of 'Accepted' proposals (which are the active projects).
  List<Proposal> get acceptedProposals => _proposals.where((p) => p.status == ProposalStatus.Accepted).toList();

  /// Returns a filtered list of proposals with 'Declined' status.
  List<Proposal> get declinedProposals => _proposals.where((p) => p.status == ProposalStatus.Declined).toList();

  /// Calculates the total sum of money yet to be paid for all accepted projects.
  double get totalPendingEarnings {
    return acceptedProposals.fold(0.0, (sum, p) => sum + (p.offeredAmount - p.amountPaid));
  }

  /// Calculates the total sum of all money ever received across all projects.
  double get totalReceivedEarnings {
    return _proposals.fold(0.0, (sum, p) => sum + p.amountPaid);
  }

  // --- Private State Mutation Helper ---

  /// A private, safe, and robust helper method to update any proposal in the list.
  ///
  /// This is the ONLY method that should directly modify the [_proposals] list.
  /// It finds a proposal by its ID and creates a new instance, preserving all
  /// old data unless a new value is explicitly provided for a specific property.
  void _updateProposal(String proposalId, {
    ProposalStatus? newStatus,
    double? newAmountPaid,
    DateTime? newDeadline,
    bool? newIsComplete,
  }) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      _proposals[index] = Proposal(
        id: old.id,
        projectTitle: old.projectTitle,
        field: old.field,
        offeredAmount: old.offeredAmount,
        submissionDate: old.submissionDate,
        // For each property, use the new value if it's not null, otherwise keep the old one.
        status: newStatus ?? old.status,
        amountPaid: newAmountPaid ?? old.amountPaid,
        deadline: newDeadline ?? old.deadline,
        isComplete: newIsComplete ?? old.isComplete,
      );
      // This crucial line notifies all listening widgets (like the UI screens)
      // that the state has changed and they need to rebuild.
      notifyListeners();
    }
  }

  // --- Public Methods (The API for the UI to interact with) ---

  /// Adds a newly created proposal to the list and notifies listeners.
  void addProposal(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
  }

  /// Changes a proposal's status to 'Accepted'.
  void acceptProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Accepted);

  /// Changes a proposal's status to 'Declined'.
  void declineProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Declined);

  /// Reverts an Accepted or Declined proposal back to the 'Active' state.
  /// Also resets payment and completion status for a clean slate.
  void reopenProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Active, newAmountPaid: 0.0, newIsComplete: false);

  /// Adds an installment payment to a specific proposal's `amountPaid` tracker.
  void addPayment(String proposalId, double paymentAmount) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      // Safely calculate the new total, ensuring it cannot exceed the offered amount.
      final newTotalPaid = (old.amountPaid + paymentAmount).clamp(0.0, old.offeredAmount);
      _updateProposal(proposalId, newAmountPaid: newTotalPaid);
    }
  }

  /// Finds a proposal by its ID and updates its deadline property.
  void setDeadline(String proposalId, DateTime deadline) {
    _updateProposal(proposalId, newDeadline: deadline);
  }

  /// Permanently marks a project as complete.
  void markProjectAsComplete(String proposalId) {
    _updateProposal(proposalId, newIsComplete: true);
  }
}