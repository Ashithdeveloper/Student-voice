import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Search Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
