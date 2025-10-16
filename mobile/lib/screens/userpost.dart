import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'comment_screen.dart';

class UserPostsPage extends StatefulWidget {
  final String token;
  const UserPostsPage({super.key, required this.token});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  bool _isLoading = true;
  List<dynamic> userPosts = [];
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    setState(() => _isLoading = true);
    try {
      final url = "https://student-voice.onrender.com/api/post/userpostlist";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userPosts = data['posts'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    // Optimistic UI update
    final newPost = {
      "_id": DateTime.now().millisecondsSinceEpoch.toString(),
      "text": text,
      "likes": [],
      "createdAt": DateTime.now().toIso8601String(),
      "user": {"name": "You"}
    };
    setState(() {
      userPosts.insert(0, newPost);
      _postController.clear();
    });

    try {
      final url = "https://student-voice.onrender.com/api/post/postcreate";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: json.encode({"text": text}),
      );

      if (response.statusCode == 200) {
        await _fetchUserPosts(); // reload real posts after success
      } else {
        // Remove optimistic post if failed
        setState(() {
          userPosts.remove(newPost);
        });
        debugPrint("❌ Failed to create post: ${response.body}");
      }
    } catch (e) {
      setState(() {
        userPosts.remove(newPost);
      });
      debugPrint("❌ Exception creating post: $e");
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _toggleLike(String id, List<dynamic> likes) async {
    try {
      final url = "https://student-voice.onrender.com/api/post/$id/like";
      await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"},
      );
    } catch (e) {
      debugPrint("❌ Exception toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Posts")),
      body: RefreshIndicator(
        onRefresh: _fetchUserPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Create Post Area
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _isPosting ? null : _createPost,
                          child: _isPosting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text("Post"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // User Posts
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : userPosts.isEmpty
                ? const Center(child: Text("You haven't created any posts yet."))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                final likes = List<dynamic>.from(post['likes'] ?? []);
                final isLiked = likes.contains(widget.token);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: const Text("Y", style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "You",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Text(
                                post['createdAt'] != null
                                    ? DateTime.parse(post['createdAt']).toLocal().toString().substring(0, 16)
                                    : "",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post['text'] ?? ""),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (isLiked) {
                                      likes.remove(widget.token);
                                    } else {
                                      likes.add(widget.token);
                                    }
                                    post['likes'] = likes;
                                  });
                                  _toggleLike(post['_id'], likes);
                                },
                                icon: Icon(
                                  likes.contains(widget.token) ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.redAccent,
                                ),
                              ),
                              Text("${likes.length}"),
                              const SizedBox(width: 20),
                              TextButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (_) => FractionallySizedBox(
                                      heightFactor: 0.9,
                                      child: CommentBottomSheet(
                                        postId: post['_id'],
                                        token: widget.token,
                                      ),
                                    ),
                                  );
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
          ],
        ),
      ),
    );
  }
}
