import 'package:flutter/foundation.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

class ProposalService extends ChangeNotifier {
  final List<Proposal> _proposals = [
    Proposal(
      id: 'p1', projectTitle: 'Brand Logo & Style Guide', field: 'Graphic Design',
      offeredAmount: 85000.00, submissionDate: DateTime.parse('2025-09-12'),
      status: ProposalStatus.Accepted,
      amountPaid: 85000.00, // Now uses the correct property name
      deadline: DateTime.parse('2025-10-15'),
    ),
    Proposal(
      id: 'p2', projectTitle: 'Fitness Tracker App UI/UX', field: 'Mobile App Design',
      offeredAmount: 220000.00, submissionDate: DateTime.parse('2025-09-15'),
      status: ProposalStatus.Accepted,
      amountPaid: 50000.00, // Now uses the correct property name
    ),
    Proposal(
      id: 'p3', projectTitle: 'Social Media Marketing', field: 'Marketing',
      offeredAmount: 180000.00, submissionDate: DateTime.parse('2025-09-10'),
      status: ProposalStatus.Active,
    ),
  ];

  // --- GETTERS ---
  List<Proposal> get allProposals => _proposals;
  List<Proposal> get activeProposals => _proposals.where((p) => p.status == ProposalStatus.Active).toList();
  List<Proposal> get acceptedProposals => _proposals.where((p) => p.status == ProposalStatus.Accepted).toList();
  List<Proposal> get declinedProposals => _proposals.where((p) => p.status == ProposalStatus.Declined).toList();
  double get totalPendingEarnings => acceptedProposals.fold(0.0, (sum, p) => sum + (p.offeredAmount - p.amountPaid));
  double get totalReceivedEarnings => _proposals.fold(0.0, (sum, p) => sum + p.amountPaid);

  // --- PRIVATE HELPER ---
  void _updateProposal(String proposalId, {ProposalStatus? newStatus, double? newAmountPaid, DateTime? newDeadline}) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      _proposals[index] = Proposal(
        id: old.id, projectTitle: old.projectTitle, field: old.field,
        offeredAmount: old.offeredAmount, submissionDate: old.submissionDate,
        status: newStatus ?? old.status,
        amountPaid: newAmountPaid ?? old.amountPaid,
        deadline: newDeadline ?? old.deadline,
      );
      notifyListeners();
    }
  }

  // --- PUBLIC METHODS ---
  void addProposal(Proposal proposal) => _proposals.insert(0, proposal);
  void acceptProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Accepted);
  void declineProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Declined);
  void reopenProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Active, newAmountPaid: 0.0);
  void addPayment(String proposalId, double paymentAmount) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      final newTotalPaid = (old.amountPaid + paymentAmount).clamp(0.0, old.offeredAmount);
      _updateProposal(proposalId, newAmountPaid: newTotalPaid);
    }
  }
  void setDeadline(String proposalId, DateTime deadline) => _updateProposal(proposalId, newDeadline: deadline);
}