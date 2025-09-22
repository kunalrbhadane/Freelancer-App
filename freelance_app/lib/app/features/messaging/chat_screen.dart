import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String clientName;

  const ChatScreen({super.key, required this.clientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clientName),
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView( // Placeholder for actual chat bubbles
              padding: EdgeInsets.all(16),
              reverse: true,
              children: [
                _buildMessageBubble("Thanks for the update!", isMe: false),
                _buildMessageBubble("Sure, I've just pushed the latest version to the repo.", isMe: true),
              ],
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, {required bool isMe}) {
    final bubbleAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.blue : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: bubbleAlignment,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(message, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: "Send a message..."),
            ),
          ),
          IconButton(icon: Icon(Icons.send), onPressed: () {}),
        ],
      ),
    );
  }
}