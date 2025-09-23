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
      isComplete: true,
    ),
    Proposal(
      id: 'p2',
      projectTitle: 'Fitness Tracker App UI/UX',
      field: 'Mobile App Design',
      offeredAmount: 220000.00,
      submissionDate: DateTime.parse('2025-09-15'),
      status: ProposalStatus.Accepted,
      amountPaid: 50000.00,
    ),
    Proposal(
      id: 'p3',
      projectTitle: 'Social Media Marketing',
      field: 'Marketing',
      offeredAmount: 180000.00,
      submissionDate: DateTime.parse('2025-09-10'),
      status: ProposalStatus.Active,
    ),
  ];

  // --- Public Getters (Safe, read-only access to the state) ---
  List<Proposal> get allProposals => _proposals;
  List<Proposal> get activeProposals => _proposals.where((p) => p.status == ProposalStatus.Active).toList();
  List<Proposal> get acceptedProposals => _proposals.where((p) => p.status == ProposalStatus.Accepted).toList();
  List<Proposal> get declinedProposals => _proposals.where((p) => p.status == ProposalStatus.Declined).toList();
  double get totalPendingEarnings => acceptedProposals.fold(0.0, (sum, p) => sum + (p.offeredAmount - p.amountPaid));
  double get totalReceivedEarnings => _proposals.fold(0.0, (sum, p) => sum + p.amountPaid);

  // --- Private State Mutation Helper ---
  /// A private helper for making granular updates to a proposal's state.
  void _updateProposalState(String proposalId, {
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
        status: newStatus ?? old.status,
        amountPaid: newAmountPaid ?? old.amountPaid,
        deadline: newDeadline ?? old.deadline,
        isComplete: newIsComplete ?? old.isComplete,
      );
      notifyListeners();
    }
  }

  // --- Public Methods (The API for the UI to interact with) ---

  /// Adds a newly created proposal to the top of the list.
  void addProposal(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
  }

  // ⭐ STAR SERVICE: This is the new method for handling form edits.
  /// Updates an existing proposal with a new Proposal object.
  void updateProposal(Proposal updatedProposal) {
    final index = _proposals.indexWhere((p) => p.id == updatedProposal.id);
    if (index != -1) {
      // Replaces the entire object at the specific index.
      _proposals[index] = updatedProposal;
      notifyListeners();
    }
  }

  // ⭐ STAR SERVICE: This is the new method for removing proposals.
  /// Removes a proposal from the list by its unique ID.
  void deleteProposal(String proposalId) {
    _proposals.removeWhere((p) => p.id == proposalId);
    notifyListeners();
  }

  /// Changes a proposal's status to 'Accepted'.
  void acceptProposal(String proposalId) => _updateProposalState(proposalId, newStatus: ProposalStatus.Accepted);

  /// Changes a proposal's status to 'Declined'.
  void declineProposal(String proposalId) => _updateProposalState(proposalId, newStatus: ProposalStatus.Declined);

  /// Reverts a proposal back to the 'Active' state and resets its progress.
  void reopenProposal(String proposalId) => _updateProposalState(proposalId, newStatus: ProposalStatus.Active, newAmountPaid: 0.0, newIsComplete: false);

  /// Adds an installment payment to a project.
  void addPayment(String proposalId, double paymentAmount) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      final newTotalPaid = (old.amountPaid + paymentAmount).clamp(0.0, old.offeredAmount);
      _updateProposalState(proposalId, newAmountPaid: newTotalPaid);
    }
  }

  /// Updates a project's deadline.
  void setDeadline(String proposalId, DateTime deadline) {
    _updateProposalState(proposalId, newDeadline: deadline);
  }

  /// Marks a project as complete.
  void markProjectAsComplete(String proposalId) {
    _updateProposalState(proposalId, newIsComplete: true);
  }
}