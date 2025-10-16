import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String token;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.token,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  List<dynamic> comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    // Poll every 5 seconds for new comments
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchComments();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      final url = "https://student-voice.onrender.com/api/post/allpostlist";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final post = (data['posts'] as List<dynamic>)
            .firstWhere((p) => p['_id'] == widget.postId);
        final newComments = post['comments'] ?? [];

        // Merge new comments and avoid duplicates
        setState(() {
          final existingIds =
          comments.map((c) => c['createdAt'] + c['text']).toSet();
          for (var c in newComments) {
            final id = (c['createdAt'] ?? "") + (c['text'] ?? "");
            if (!existingIds.contains(id)) {
              comments.add(c);
            }
          }
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Error fetching comments: $e");
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // Optimistic UI update
    final newComment = {
      "text": text,
      "user": {"name": "You"},
      "createdAt": DateTime.now().toIso8601String()
    };
    setState(() {
      comments.add(newComment);
      _commentController.clear();
    });
    _scrollToBottom();

    try {
      final url =
          "https://student-voice.onrender.com/api/post/${widget.postId}/comment";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}"
        },
        body: json.encode({"text": text}),
      );

      if (response.statusCode != 200) {
        setState(() {
          comments.remove(newComment);
        });
        debugPrint("❌ Failed to send comment: ${response.body}");
      }
    } catch (e) {
      setState(() {
        comments.remove(newComment);
      });
      debugPrint("❌ Exception sending comment: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return updated comments to parent
        Navigator.pop(context, comments);
        return false;
      },
      child: SafeArea(
        child: Column(
          children: [
            // Top handle
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? const Center(child: Text("No comments yet"))
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final user = comment['user'] ?? {};
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? "Anonymous",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(comment['text'] ?? ""),
                              const SizedBox(height: 4),
                              Text(
                                comment['createdAt'] != null
                                    ? DateTime.parse(
                                    comment['createdAt'])
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16)
                                    : "",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                          hintText: "Add a comment...",
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16)),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(Icons.send, color: Colors.indigo),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
