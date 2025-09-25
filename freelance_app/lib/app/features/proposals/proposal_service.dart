import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freelance_app/app/features/proposals/proposal_model.dart';
import 'package:freelance_app/app/features/proposals/sort_option_model.dart';

/// The central state management service for all proposal and project-related data.
///
/// This class handles loading/saving data from the device, managing temporary
/// view-state like search/filter/sort, and providing the business logic for all
/// data mutations. It uses the [ChangeNotifier] pattern to alert the UI about
/// any data changes, ensuring the app is always in sync.
class ProposalService extends ChangeNotifier {
  // --- Private State Data ---
  static const _proposalsStorageKey = 'proposals_data_v1';
  
  // The complete, persisted list of all proposals. This is the single source of truth.
  List<Proposal> _proposals = [];

  // View-state variables (temporary UI state, not saved to persistence).
  String _searchQuery = '';
  String? _activeFilterField;
  SortOption _currentSortOrder = SortOption.newestFirst;

  /// Constructor: Immediately begins loading saved data when the app starts.
  ProposalService() {
    _loadProposals();
  }

  // --- Public Getters (Safe, read-only access to state) ---

  /// ⭐ Returns the complete, unfiltered list of all proposals. Essential for lookups.
  List<Proposal> get allProposals => _proposals;

  /// Provides the currently active sort order so the UI can display it.
  SortOption get currentSortOrder => _currentSortOrder;

  /// Returns a dynamically filtered, searched, and sorted list for the UI.
  List<Proposal> get filteredAndSearchedProposals {
    List<Proposal> result = _proposals;
    
    // 1. Apply field filter (if active)
    if (_activeFilterField != null) {
      result = result.where((p) => p.field == _activeFilterField).toList();
    }
    // 2. Apply search query (if active)
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) => p.projectTitle.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // 3. Apply the final sorting logic based on the current state.
    switch (_currentSortOrder) {
      case SortOption.newestFirst:
        result.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
        break;
      case SortOption.highestBudget:
        result.sort((a, b) => b.offeredAmount.compareTo(a.offeredAmount));
        break;
      case SortOption.byDeadline:
        result.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
    }
    return result;
  }
  
  // Tab-specific getters that are already filtered, searched, and sorted.
  List<Proposal> get activeProposals => filteredAndSearchedProposals.where((p) => p.status == ProposalStatus.Active).toList();
  List<Proposal> get acceptedProposals => filteredAndSearchedProposals.where((p) => p.status == ProposalStatus.Accepted).toList();
  List<Proposal> get declinedProposals => filteredAndSearchedProposals.where((p) => p.status == ProposalStatus.Declined).toList();
  
  // Financial getters that always operate on the full, unfiltered list for accuracy.
  double get totalPendingEarnings => _proposals.where((p) => p.status == ProposalStatus.Accepted).fold(0.0, (sum, p) => sum + (p.offeredAmount - p.amountPaid));
  double get totalReceivedEarnings => _proposals.fold(0.0, (sum, p) => sum + p.amountPaid);
  
  // View-state helpers for the UI.
  static const List<String> predefinedFields = ['Web Development', 'Mobile App Design', 'Graphic Design', 'Marketing', 'Content Writing', 'Video Editing', 'UI/UX Research'];
  bool isActiveFilter(String field) => _activeFilterField == field;
  bool get hasActiveFilterOrSearch => _searchQuery.isNotEmpty || _activeFilterField != null;
  
  // --- Persistence Methods ---
  Future<void> _saveProposals() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> proposalMaps = _proposals.map((p) => p.toJson()).toList();
    await prefs.setString(_proposalsStorageKey, json.encode(proposalMaps));
  }

  Future<void> _loadProposals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_proposalsStorageKey);
    if (encodedData != null && encodedData.isNotEmpty) {
      final List<dynamic> decodedData = json.decode(encodedData);
      _proposals = decodedData.map((jsonMap) => Proposal.fromJson(jsonMap)).toList();
    } else {
      _proposals = _getInitialMockData();
      await _saveProposals(); // Save the initial data on the very first launch.
    }
    notifyListeners();
  }
  
  // --- Public Methods for State Mutation ---
  void setSortOrder(SortOption newOrder) {
    if (_currentSortOrder != newOrder) {
      _currentSortOrder = newOrder;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void toggleFilter(String field) {
    _activeFilterField = (_activeFilterField == field) ? null : field;
    notifyListeners();
  }
  
  void addProposal(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
    _saveProposals();
  }

  void updateProposal(Proposal updatedProposal) {
    final index = _proposals.indexWhere((p) => p.id == updatedProposal.id);
    if (index != -1) {
      _proposals[index] = updatedProposal;
      notifyListeners();
      _saveProposals();
    }
  }

  void deleteProposal(String proposalId) {
    _proposals.removeWhere((p) => p.id == proposalId);
    notifyListeners();
    _saveProposals();
  }
  
  void acceptProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Accepted);
  void declineProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Declined);
  void reopenProposal(String proposalId) => _updateAndSaveProposalState(proposalId, newStatus: ProposalStatus.Active, newAmountPaid: 0.0, newIsComplete: false);
  void markProjectAsComplete(String proposalId) => _updateAndSaveProposalState(proposalId, newIsComplete: true);
  void setDeadline(String proposalId, DateTime deadline) => _updateAndSaveProposalState(proposalId, newDeadline: deadline);
  
  void addPayment(String proposalId, double paymentAmount) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      final newTotalPaid = (old.amountPaid + paymentAmount).clamp(0.0, old.offeredAmount);
      _updateAndSaveProposalState(proposalId, newAmountPaid: newTotalPaid);
    }
  }

  void _updateAndSaveProposalState(String proposalId, {
    ProposalStatus? newStatus, double? newAmountPaid, DateTime? newDeadline, bool? newIsComplete,
  }) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index != -1) {
      final old = _proposals[index];
      _proposals[index] = Proposal(
        id: old.id, projectTitle: old.projectTitle, field: old.field, description: old.description, 
        offeredAmount: old.offeredAmount, submissionDate: old.submissionDate,
        status: newStatus ?? old.status, amountPaid: newAmountPaid ?? old.amountPaid, 
        deadline: newDeadline ?? old.deadline, isComplete: newIsComplete ?? old.isComplete,
      );
      notifyListeners();
      _saveProposals();
    }
  }
  
  List<Proposal> _getInitialMockData() {
    return [
      Proposal(id: 'p1', projectTitle: 'Brand Logo & Style Guide', field: 'Graphic Design', description: 'Create a modern and memorable logo for a new tech startup, including a full style guide with color palettes and typography.', offeredAmount: 85000.00, submissionDate: DateTime.parse('2025-09-12'), status: ProposalStatus.Accepted, amountPaid: 85000.00, deadline: DateTime.parse('2025-10-15'), isComplete: true),
      Proposal(id: 'p2', projectTitle: 'Fitness Tracker App UI/UX', field: 'Mobile App Design', description: 'Design the user interface and experience for a new cross-platform fitness application. Key screens include dashboard, workout log, and user profile.', offeredAmount: 220000.00, submissionDate: DateTime.parse('2025-09-15'), status: ProposalStatus.Accepted, amountPaid: 50000.00, deadline: DateTime.parse('2025-11-20')),
      Proposal(id: 'p3', projectTitle: 'Social Media Marketing', field: 'Marketing', description: 'Develop and execute a 3-month social media marketing campaign for a local business to increase brand awareness and engagement.', offeredAmount: 180000.00, submissionDate: DateTime.parse('2025-09-10'), status: ProposalStatus.Active),
      Proposal(id: 'p4', projectTitle: 'E-commerce Website Backend', field: 'Web Development', description: 'Build a scalable backend for an e-commerce platform using Node.js and Postgres.', offeredAmount: 350000.00, submissionDate: DateTime.parse('2025-09-18'), status: ProposalStatus.Active),
    ];
  }
}