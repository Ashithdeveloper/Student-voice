import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home/mainpage.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> answers = [];
  int currentIndex = 0;
  bool _isLoading = true;
  String? token;
  String? collegeName;
  bool _surveySubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchQuestions();
  }

  Future<void> _loadTokenAndFetchQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await _fetchQuestions();
      await _checkSurveyStatus();
    } else {
      setState(() => _isLoading = false);
      debugPrint("⚠️ No token found");
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse("https://student-voice.onrender.com/api/questions"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? fetchedQuestions = data['question']?['questions'];
        if (fetchedQuestions != null && fetchedQuestions.isNotEmpty) {
          questions = List<Map<String, dynamic>>.from(fetchedQuestions);
          collegeName = data['question']['collegename'];
        } else {
          questions = [];
        }
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSurveyStatus() async {
    try {
      final response = await http.get(
        Uri.parse("https://student-voice.onrender.com/api/questions/check-survey"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _surveySubmitted = data['submitted'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error checking survey status: $e");
    }
  }

  void _submitAnswer(String answerText) {
    if (_surveySubmitted) return;

    final currentQuestion = questions[currentIndex];
    answers.add({
      "id": currentQuestion['id'],
      "question": currentQuestion['question'],
      "answer": answerText,
    });

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      _submitSurvey();
    }
  }

  Future<void> _submitSurvey() async {
    final payload = {
      "collegename": collegeName ?? "Unknown College",
      "answers": answers,
    };

    try {
      final response = await http.post(
        Uri.parse("https://student-voice.onrender.com/api/questions/answer"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() => _surveySubmitted = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Submission failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error submitting survey: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(child: Text("No questions available")),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.poll, color: Colors.indigo, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collegeName ?? "Survey",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _surveySubmitted
                              ? "Survey submitted successfully ✅ next survey after 6 months"
                              : "Question ${currentIndex + 1} of ${questions.length}",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Question Card or completion message
              Expanded(
                child: _surveySubmitted
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 80),
                      const SizedBox(height: 20),
                      const Text(
                        "Survey Submitted Successfully!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Thank you for your feedback!",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate back to home
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MainPage()),
                                  (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Back to Home",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion['question'] ?? "No question text",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (currentQuestion['options'] != null &&
                          currentQuestion['options'] is List<dynamic> &&
                          (currentQuestion['options'] as List).isNotEmpty)
                        ...List<Widget>.from(
                          (currentQuestion['options'] as List<dynamic>)
                              .map<Widget>((option) {
                            final text = option['text'] ?? "No option";
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _submitAnswer(text),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.indigo.shade50,
                                  foregroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(text,
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          }),
                        )
                      else
                        SurveyTextInput(onSubmit: _submitAnswer),

                      const Spacer(),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: LinearProgressIndicator(
                            value: (currentIndex + 1) / questions.length,
                            minHeight: 8,
                            color: Colors.indigo,
                            backgroundColor: Colors.indigo.shade50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyTextInput extends StatefulWidget {
  final Function(String) onSubmit;
  const SurveyTextInput({super.key, required this.onSubmit});

  @override
  State<SurveyTextInput> createState() => _SurveyTextInputState();
}

class _SurveyTextInputState extends State<SurveyTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Type your answer here...",
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _isFocused ? Colors.indigo : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.indigo,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSubmit(_controller.text.trim());
                _controller.clear();
                FocusScope.of(context).unfocus();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Next", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
