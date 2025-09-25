/// Defines the available options for sorting the proposal list.
///
/// Using an enum provides type safety and makes the sorting logic
/// in the service much cleaner and less error-prone.
enum SortOption {
  /// Sorts by submission date, with the most recent proposal appearing first.
  newestFirst,
  
  /// Sorts by the offered amount, with the highest budget appearing first.
  highestBudget,
  
  /// Sorts by the project deadline, with the soonest deadline appearing first.
  /// Proposals without a set deadline will appear at the bottom of the list.
  byDeadline,
}