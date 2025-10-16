import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        });
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

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
          "Content-Type": "application/json",
        },
        body: json.encode({"text": text}),
      );

      if (response.statusCode == 200) {
        await _fetchUserPosts();
      } else {
        userPosts.remove(newPost);
      }
    } catch (e) {
      userPosts.remove(newPost);
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _toggleLike(String id, List<dynamic> likes) async {
    try {
      final url = "https://student-voice.onrender.com/api/post/$id/like";
      await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
    } catch (e) {
      debugPrint("❌ Like Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchUserPosts,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const Text(
                    "Your Posts",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Post Input Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _postController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "Share your thoughts...",
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: _isPosting ? null : _createPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            icon: _isPosting
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                                : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "Post",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Posts List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Colors.indigo),
                      ),
                    )
                  else if (userPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text(
                        "You haven't created any posts yet.",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        final likes = List<dynamic>.from(post['likes'] ?? []);
                        final isLiked = likes.contains(widget.token);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.indigo,
                                      child: Text(
                                        "Y",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "You",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      post['createdAt'] != null
                                          ? DateTime.parse(post['createdAt'])
                                          .toLocal()
                                          .toString()
                                          .substring(0, 16)
                                          : "",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post['text'] ?? "",
                                  style: const TextStyle(fontSize: 15),
                                ),
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
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
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
                                          shape:
                                          const RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.vertical(
                                                top:
                                                Radius.circular(20)),
                                          ),
                                          builder: (_) =>
                                              FractionallySizedBox(
                                                heightFactor: 0.9,
                                                child: CommentBottomSheet(
                                                  postId: post['_id'],
                                                  token: widget.token,
                                                ),
                                              ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.comment_outlined,
                                          color: Colors.indigo),
                                      label: const Text(
                                        "Comment",
                                        style: TextStyle(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.w500),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
