import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MentorTab extends StatefulWidget {
  const MentorTab({super.key});

  @override
  State<MentorTab> createState() => _MentorTabState();
}

class _MentorTabState extends State<MentorTab> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  String? token;

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  String _formatResponse(String rawText) {
    String cleaned = rawText
        .replaceAll(RegExp(r'chartData|null', caseSensitive: false), '')
        .replaceAll(RegExp(r'youtube links?', caseSensitive: false), '')
        .replaceAll(RegExp(r"[';:]"), '')
        .replaceAll(RegExp(r'```json|```'), '')
        .replaceAll(RegExp(r'[\\#*_`{}[\]"]'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

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
              if (desc.isNotEmpty) output += '• $category: $desc\n';
            }
          }
        }
        return output.trim();
      }
    } catch (_) {}
    cleaned = cleaned.replaceAllMapped(RegExp(r'n\d+'), (_) => '\n•');
    return cleaned.trim();
  }

  Future<void> _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || token == null) return;

    setState(() => _isSending = true);

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

        if (formattedResponse.isNotEmpty) {
          setState(() {
            messages.add({"sender": "mentor", "text": formattedResponse});
          });
        }
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
          duration: const Duration(milliseconds: 250),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.indigo.shade900,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade50,
              child: const Icon(Icons.school_rounded,
                  size: 50, color: Colors.indigo),
            ),
            const SizedBox(height: 25),
            Text(
              "AI Mentor",
              style: TextStyle(
                fontSize: 26,
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ask your mentor for career advice, learning paths,\nor skill-building guidance — personalized for you.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMessages = messages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: constraints.maxHeight -
                        MediaQuery.of(context).viewInsets.bottom,
                    child: hasMessages
                        ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildChatBubble(messages[index]);
                      },
                    )
                        : _buildIntroSection(),
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),
                Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: Scrollbar(
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "Ask your mentor...",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
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
                                : const Icon(Icons.send_rounded,
                                color: Colors.white),
                            onPressed: _isSending ? null : _sendPrompt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
