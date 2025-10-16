import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screens/comment_screen.dart';
import '../screens/userpost.dart';


class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  bool _isLoading = true;
  List<dynamic> posts = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchPosts();
  }

  Future<void> _loadTokenAndFetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    await _fetchAllPosts();
  }

  Future<void> _fetchAllPosts() async {
    setState(() => _isLoading = true);
    try {
      final url = "https://student-voice.onrender.com/api/post/allpostlist";
      final response = await http.get(
        Uri.parse(url),
        headers: token != null ? {"Authorization": "Bearer $token"} : {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['posts'] ?? [];
          _isLoading = false;
        });
        debugPrint("✅ Fetched Posts: $data");
      } else {
        setState(() => _isLoading = false);
        debugPrint("❌ Failed to fetch posts: ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Exception fetching posts: $e");
    }
  }

  Future<void> _toggleLike(String id) async {
    if (token == null) return;

    try {
      final url = "https://student-voice.onrender.com/api/post/$id/like";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Like toggled for post $id: ${response.body}");
      } else {
        debugPrint(
            "❌ Failed to toggle like for post $id: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception toggling like for post $id: $e");
    }
  }

  // Navigate to UserPostsPage
  void _openUserPostsPage() async {
    if (token == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserPostsPage(token: token!)),
    );
    // Refresh all posts in case user updated something
    await _fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Community"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // + icon
            onPressed: _openUserPostsPage, // navigate to UserPostsPage
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchAllPosts,
          child: posts.isEmpty
              ? ListView(
            children: const [
              SizedBox(height: 100),
              Center(
                child: Text(
                  "No posts available",
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final user = post['user'] ?? {};
              final likes = List<dynamic>.from(post['likes'] ?? []);
              final isLiked = token != null && likes.contains(token);

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.indigo.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Text(
                                (user['name'] != null &&
                                    user['name'].isNotEmpty)
                                    ? user['name'][0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user['name'] ?? "Anonymous",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              post['createdAt'] != null
                                  ? DateTime.parse(post['createdAt'])
                                  .toLocal()
                                  .toString()
                                  .substring(0, 16)
                                  : "",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post['text'] ?? "",
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (post['media'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(post['media']),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                setState(() {
                                  if (isLiked) {
                                    likes.remove(token);
                                  } else {
                                    likes.add(token);
                                  }
                                  post['likes'] = likes;
                                });
                                await _toggleLike(post['_id']);
                              },
                              icon: Icon(
                                likes.contains(token)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text("${likes.length}"),
                            const SizedBox(width: 20),
                            TextButton.icon(
                              onPressed: () {
                                if (token != null) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    builder: (_) => FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: CommentBottomSheet(
                                          postId: post['_id'],
                                          token: token!),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.comment_outlined),
                              label: const Text("Comment"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
