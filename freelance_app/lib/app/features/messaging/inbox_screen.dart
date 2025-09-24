import 'package:flutter/material.dart';
import 'package:freelance_app/app/features/messaging/conversation_model.dart';
import 'package:freelance_app/app/features/messaging/chat_screen.dart';

class InboxScreen extends StatelessWidget {
  final List<Conversation> conversations = [
    Conversation(id: 'c1', clientName: 'John Doe', avatarUrl: 'https://via.placeholder.com/150/92c952', lastMessage: 'Okay, sounds good!', timestamp: '10:42 AM', isOnline: true),
    Conversation(id: 'c2', clientName: 'Jane Smith', avatarUrl: 'https://via.placeholder.com/150/771796', lastMessage: 'Can you check the latest file?', timestamp: 'Yesterday'),
  ];

InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(conversation.avatarUrl)),
            title: Text(conversation.clientName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(conversation.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(conversation.timestamp),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(clientName: conversation.clientName),
              ));
            },
          );
        },
      ),
    );
  }
}