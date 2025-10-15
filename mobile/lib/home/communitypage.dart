import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  bool _isLoading = true;
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchAllPosts();
  }

  Future<void> _fetchAllPosts() async {
    try {
      final url = "https://student-voice.onrender.com/api/post/allpostlist";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['posts'] ?? []; // adjust according to your API response
          _isLoading = false;
        });
        debugPrint("✅ Fetched Posts: $data"); // log full response
      } else {
        setState(() => _isLoading = false);
        debugPrint("❌ Failed to fetch posts: ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Exception fetching posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Community"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(
        child: Text(
          "No posts available",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post['title'] ?? "No title"),
            subtitle: Text(post['content'] ?? "No content"),
          );
        },
      ),
    );
  }
}
