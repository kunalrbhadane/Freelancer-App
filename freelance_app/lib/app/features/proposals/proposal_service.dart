import 'dart:convert'; // Required for json.encode and json.decode
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the persistence package

import 'package:freelance_app/app/features/proposals/proposal_model.dart';

/// The central state management service for all proposal and project-related data.
/// This class handles loading data from storage, modifying it in memory, and
/// instantly saving every change back to storage.
class ProposalService extends ChangeNotifier {
  // The unique key for storing the proposals JSON string in SharedPreferences.
  static const _proposalsStorageKey = 'proposals_data_v1';

  // The in-memory list of proposals. It starts empty and is populated by _loadProposals.
  List<Proposal> _proposals = [];

  ProposalService() {
    // When the service is created (at app startup), immediately load the data.
    _loadProposals();
  }

  // --- Public Getters (Safe, read-only access to the current state) ---
  List<Proposal> get allProposals => _proposals;
  List<Proposal> get activeProposals => _proposals.where((p) => p.status == ProposalStatus.Active).toList();
  List<Proposal> get acceptedProposals => _proposals.where((p) => p.status == ProposalStatus.Accepted).toList();
  List<Proposal> get declinedProposals => _proposals.where((p) => p.status == ProposalStatus.Declined).toList();
  double get totalPendingEarnings => acceptedProposals.fold(0.0, (sum, p) => sum + (p.offeredAmount - p.amountPaid));
  double get totalReceivedEarnings => _proposals.fold(0.0, (sum, p) => sum + p.amountPaid);

  // --- Persistence Methods ---

  /// Asynchronously saves the current `_proposals` list to the device's local storage.
  Future<void> _saveProposals() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the List<Proposal> to a List<Map>, then encode it into a JSON string.
    final List<Map<String, dynamic>> proposalMaps = _proposals.map((p) => p.toJson()).toList();
    final String encodedData = json.encode(proposalMaps);
    await prefs.setString(_proposalsStorageKey, encodedData);
  }

  /// Asynchronously loads proposals from local storage. If no data exists, it loads initial mock data.
  Future<void> _loadProposals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_proposalsStorageKey);

    if (encodedData != null && encodedData.isNotEmpty) {
      // If data exists, decode the JSON string into a List<dynamic> of maps.
      final List<dynamic> decodedData = json.decode(encodedData);
      // Map over the list, converting each map back into a full Proposal object.
      _proposals = decodedData.map((json) => Proposal.fromJson(json)).toList();
    } else {
      // If no data is found (first app launch), populate the list with default mock data.
      _proposals = _getInitialMockData();
    }
    // Notify all listening UI widgets that data is ready.
    notifyListeners();
  }

  // --- Public Methods (The API for the UI to interact with) ---
  // Each method modifies the in-memory list, notifies listeners, and then saves the changes.

  /// Adds a new proposal to the list and saves.
  void addProposal(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
    _saveProposals();
  }

  /// Replaces an existing proposal with an updated version and saves.
  void updateProposal(Proposal updatedProposal) {
    final index = _proposals.indexWhere((p) => p.id == updatedProposal.id);
    if (index != -1) {
      _proposals[index] = updatedProposal;
      notifyListeners();
      _saveProposals();
    }
  }

  /// Removes a proposal from the list by its ID and saves.
  void deleteProposal(String proposalId) {
    _proposals.removeWhere((p) => p.id == proposalId);
    notifyListeners();
    _saveProposals();
  }
  
  // --- Methods that use the private state update helper ---

  /// A private helper that performs a granular update, notifies listeners, and saves.
  void _updateAndSaveProposalState(String proposalId, {
    ProposalStatus? newStatus,
    double? newAmountPaid,
    DateTime? newDeadline,
    bool? newIsComplete,
  }) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      _proposals[index] = Proposal(
        id: old.id, projectTitle: old.projectTitle, field: old.field,
        offeredAmount: old.offeredAmount, submissionDate: old.submissionDate,
        status: newStatus ?? old.status, amountPaid: newAmountPaid ?? old.amountPaid,
        deadline: newDeadline ?? old.deadline, isComplete: newIsComplete ?? old.isComplete,
      );
      notifyListeners();
      _saveProposals();
    }
  }

  /// Changes a proposal's status to 'Accepted' and saves.
  void acceptProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Accepted);

  /// Changes a proposal's status to 'Declined' and saves.
  void declineProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Declined);

  /// Reverts a proposal to 'Active', resets progress, and saves.
  void reopenProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Active, newAmountPaid: 0.0, newIsComplete: false);

  /// Adds a payment to a project and saves.
  void addPayment(String proposalId, double paymentAmount) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      final newTotalPaid = (old.amountPaid + paymentAmount).clamp(0.0, old.offeredAmount);
      _updateAndSaveProposalState(proposalId, newAmountPaid: newTotalPaid);
    }
  }

  /// Sets a project's deadline and saves.
  void setDeadline(String proposalId, DateTime deadline) => _updateAndSaveProposalState(proposalId, newDeadline: deadline);

  /// Marks a project as complete and saves.
  void markProjectAsComplete(String proposalId) => _updateAndSaveProposalState(proposalId, newIsComplete: true);
  
  // --- Initial Data ---

  /// Provides a default list of proposals for the very first app launch.
  List<Proposal> _getInitialMockData() {
    return [
      Proposal(
        id: 'p1', projectTitle: 'Brand Logo & Style Guide', field: 'Graphic Design',
        offeredAmount: 85000.00, submissionDate: DateTime.parse('2025-09-12'),
        status: ProposalStatus.Accepted, amountPaid: 85000.00,
        deadline: DateTime.parse('2025-10-15'), isComplete: true,
      ),
      Proposal(
        id: 'p2', projectTitle: 'Fitness Tracker App UI/UX', field: 'Mobile App Design',
        offeredAmount: 220000.00, submissionDate: DateTime.parse('2025-09-15'),
        status: ProposalStatus.Accepted, amountPaid: 50000.00,
      ),
      Proposal(
        id: 'p3', projectTitle: 'Social Media Marketing', field: 'Marketing',
        offeredAmount: 180000.00, submissionDate: DateTime.parse('2025-09-10'),
        status: ProposalStatus.Active,
      ),
    ];
  }
}