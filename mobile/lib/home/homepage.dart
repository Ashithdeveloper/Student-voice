import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Student Voice"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Home Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
