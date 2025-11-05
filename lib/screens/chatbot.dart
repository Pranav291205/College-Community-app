import 'package:flutter/material.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatBot"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: Text(
            "Welcome to ChatBot ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
