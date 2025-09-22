import 'package:flutter/foundation.dart';
import 'package:freelance_app/app/features/proposals/proposal_model.dart';

// ⭐ STAR SERVICE: Now that the Proposal model is correct, this service file
// will compile without any "undefined" errors.
class ProposalService extends ChangeNotifier {
  final List<Proposal> _proposals = [
    Proposal(
      id: 'p1',
      projectTitle: 'Brand Logo & Style Guide',
      field: 'Graphic Design',
      offeredAmount: 85000.00,
      submissionDate: DateTime.parse('2025-09-12'),
      status: ProposalStatus.Accepted,
      // We can now correctly set the initial payment status
      paymentStatus: PaymentStatus.Paid,
    ),
    Proposal(
      id: 'p2',
      projectTitle: 'Fitness Tracker App UI/UX',
      field: 'Mobile App Design',
      offeredAmount: 220000.00,
      submissionDate: DateTime.parse('2025-09-15'),
      status: ProposalStatus.Accepted,
      // This project is accepted but awaiting payment
      paymentStatus: PaymentStatus.Unpaid,
    ),
    Proposal(
      id: 'p3',
      projectTitle: 'Social Media Marketing',
      field: 'Marketing',
      offeredAmount: 180000.00,
      submissionDate: DateTime.parse('2025-09-10'),
      status: ProposalStatus.Active,
      // Its payment status is also Unpaid by default
    ),
  ];

  // --- GETTERS ---
  List<Proposal> get allProposals => _proposals;
  List<Proposal> get activeProposals => _proposals.where((p) => p.status == ProposalStatus.Active).toList();
  List<Proposal> get acceptedProposals => _proposals.where((p) => p.status == ProposalStatus.Accepted).toList();
  List<Proposal> get declinedProposals => _proposals.where((p) => p.status == ProposalStatus.Declined).toList();

  /// Calculates the sum of all ACCEPTED proposals that are currently UNPAID.
  double get totalPendingEarnings {
    return _proposals
        .where((p) => p.status == ProposalStatus.Accepted && p.paymentStatus == PaymentStatus.Unpaid)
        .fold(0.0, (sum, proposal) => sum + proposal.offeredAmount);
  }

  /// Calculates the sum of all proposals that have been PAID.
  double get totalReceivedEarnings {
    return _proposals
        .where((p) => p.paymentStatus == PaymentStatus.Paid)
        .fold(0.0, (sum, proposal) => sum + proposal.offeredAmount);
  }

  // --- METHODS ---
  void addProposal(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
  }

  void _updateProposal(String proposalId, {ProposalStatus? newStatus, PaymentStatus? newPaymentStatus}) {
      final index = _proposals.indexWhere((p) => p.id == proposalId);
      if (index != -1) {
          final oldProposal = _proposals[index];
          _proposals[index] = Proposal(
              id: oldProposal.id,
              projectTitle: oldProposal.projectTitle,
              field: oldProposal.field,
              offeredAmount: oldProposal.offeredAmount,
              submissionDate: oldProposal.submissionDate,
              // Use the new status if provided, otherwise keep the old one
              status: newStatus ?? oldProposal.status,
              // Use the new payment status if provided, otherwise keep the old one
              paymentStatus: newPaymentStatus ?? oldProposal.paymentStatus,
          );
          notifyListeners();
      }
  }

  void acceptProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Accepted);
  void declineProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Declined);
  void reopenProposal(String proposalId) => _updateProposal(proposalId, newStatus: ProposalStatus.Active);
  void markAsPaid(String proposalId) => _updateProposal(proposalId, newPaymentStatus: PaymentStatus.Paid);

} // This is the final closing brace for the class. No extra braces.