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
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(String id) async {
    if (token == null) return;
    try {
      final url = "https://student-voice.onrender.com/api/post/$id/like";
      await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      debugPrint("❌ Like error: $e");
    }
  }

  void _openUserPostsPage() async {
    if (token == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserPostsPage(token: token!)),
    );
    await _fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUserPostsPage,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.indigo,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Text(
                "Community",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Posts section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                  : RefreshIndicator(
                onRefresh: _fetchAllPosts,
                color: Colors.indigo,
                child: posts.isEmpty
                    ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        "No posts available",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  ],
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final user = post['user'] ?? {};
                    final likes = List<dynamic>.from(post['likes'] ?? []);
                    final isLiked = token != null && likes.contains(token);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Info Row
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Text(
                                    (user['name'] != null &&
                                        user['name'].isNotEmpty)
                                        ? user['name'][0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? "Anonymous",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        post['createdAt'] != null
                                            ? DateTime.parse(post['createdAt'])
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16)
                                            : "",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Post Text
                            Text(
                              post['text'] ?? "",
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),

                            if (post['media'] != null)
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 10, bottom: 4),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  child: Image.network(
                                    post['media'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Actions Row
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
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
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    Text(
                                      "${likes.length}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (token != null) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape:
                                        const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                        ),
                                        builder: (_) =>
                                            FractionallySizedBox(
                                              heightFactor: 0.9,
                                              child: CommentBottomSheet(
                                                postId: post['_id'],
                                                token: token!,
                                              ),
                                            ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.mode_comment_outlined,
                                    color: Colors.indigo,
                                  ),
                                  label: const Text(
                                    "Comment",
                                    style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
