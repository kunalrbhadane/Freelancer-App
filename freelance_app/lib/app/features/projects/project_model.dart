// lib/app/features/projects/project_model.dart

class Project {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String deadline;
  final List<String> requiredSkills;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.requiredSkills,
  });
}