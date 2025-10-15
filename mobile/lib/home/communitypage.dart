import 'package:flutter/material.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Community"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Community Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
