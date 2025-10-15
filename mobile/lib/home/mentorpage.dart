import 'package:flutter/material.dart';

class MentorTab extends StatelessWidget {
  const MentorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mentor"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Mentor Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
