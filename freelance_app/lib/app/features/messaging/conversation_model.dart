class Conversation {
  final String id;
  final String clientName;
  final String avatarUrl;
  final String lastMessage;
  final String timestamp;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.clientName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    this.isOnline = false,
  });
}