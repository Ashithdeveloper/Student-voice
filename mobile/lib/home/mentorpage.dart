import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/CreateSchedulePage.dart';

class MentorTab extends StatefulWidget {
  const MentorTab({super.key});

  @override
  State<MentorTab> createState() => _MentorTabState();
}

class _MentorTabState extends State<MentorTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  String? token;

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  /// Clean and format AI response neatly
  String _formatResponse(String rawText) {
    debugPrint("🧠 Raw Mentor Response:\n$rawText");

    // Remove unnecessary words and symbols
    String cleaned = rawText
        .replaceAll(RegExp(r'learningPlan', caseSensitive: false), '')
        .replaceAll(RegExp(r'chart data', caseSensitive: false), '')
        .replaceAll(RegExp(r'youtube links?', caseSensitive: false), '')
        .replaceAll(RegExp(r"[';:]"), '')
        .replaceAll(RegExp(r'```json|```'), '')
        .replaceAll(RegExp(r'[\\#*_`{}[\]"]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    // Try parsing JSON
    try {
      final data = json.decode(cleaned);
      if (data is Map<String, dynamic>) {
        String output = '';
        if (data.containsKey('advice')) {
          output += data['advice'].toString().trim() + '\n\n';
        }
        if (data.containsKey('learningPlan') && data['learningPlan'] is List) {
          for (var item in data['learningPlan']) {
            if (item is Map<String, dynamic>) {
              final category = item['Category'] ?? '';
              final desc = item['Description'] ?? '';
              output += '• $category: $desc\n';
            } else {
              output += '• $item\n';
            }
          }
        }
        return output.trim();
      }
    } catch (e) {
      debugPrint("⚠️ Not valid JSON: $e");
    }

    // Handle n1/n2 bullet formatting
    cleaned = cleaned.replaceAllMapped(RegExp(r'n\d+'), (_) => '\n•');

    return cleaned.trim();
  }

  Future<void> _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || token == null) return;

    setState(() => _isSending = true);

    // Add user message
    setState(() {
      messages.add({"sender": "user", "text": prompt});
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final url = Uri.parse('https://student-voice.onrender.com/api/mentorchart');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"prompt": prompt}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        String aiResponse =
            data['mentorChart']?['aiResponse'] ?? 'No response from mentor';
        final formattedResponse = _formatResponse(aiResponse);

        setState(() {
          messages.add({"sender": "mentor", "text": formattedResponse});
        });
      } else {
        setState(() {
          messages.add({
            "sender": "mentor",
            "text": "Failed to get mentor response. Try again."
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"sender": "mentor", "text": "Error sending prompt."});
      });
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
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

  Widget _buildChatBubble(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.indigo.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.indigo.shade900,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(messages[index]);
                    },
                  ),
                ),
                const Divider(height: 1),
                Container(
                  color: Colors.indigo.shade50,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 12,
                    right: 12,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "Ask your mentor...",
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(24)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.indigo,
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.send, color: Colors.white),
                          onPressed: _isSending ? null : _sendPrompt,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              top: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateSchedulePage()),
                  );
                },
                backgroundColor: Colors.indigo,
                icon: const Icon(Icons.schedule),
                label: const Text("Create Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
