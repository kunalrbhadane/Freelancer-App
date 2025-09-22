class WorkHistoryItem {
  final String projectTitle;
  final String clientName;
  final double rating;

  WorkHistoryItem({required this.projectTitle, required this.clientName, required this.rating});
}

class UserProfile {
  final String name;
  final String title;
  final String avatarUrl;
  final String bio;
  final double averageRating;
  final int totalReviews;
  final List<String> skills;
  final List<WorkHistoryItem> workHistory;

  UserProfile({
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.bio,
    required this.averageRating,
    required this.totalReviews,
    required this.skills,
    required this.workHistory,
  });
}