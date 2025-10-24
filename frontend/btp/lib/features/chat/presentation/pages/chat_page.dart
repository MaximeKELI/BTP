import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final int chatId;
  
  const ChatPage({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat $chatId'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Page de chat $chatId - En construction'),
      ),
    );
  }
}
