import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      print("⚠️ No token found");
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse("https://student-voice.onrender.com/api/questions"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("📥 Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? fetchedQuestions = data['question']?['questions'];
        if (fetchedQuestions != null && fetchedQuestions.isNotEmpty) {
          questions = List<Map<String, dynamic>>.from(fetchedQuestions);
          collegeName = data['question']['collegename'];
          print("🏫 College Name: $collegeName");
        } else {
          questions = [];
          print("⚠️ No questions found in API response");
        }
      } else {
        print("❌ Error fetching questions: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception while fetching questions: $e");
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
      } else {
        print("❌ Error checking survey status: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception checking survey status: $e");
    }
  }

  void _submitAnswer(String answerText) {
    if (_surveySubmitted) return; // Prevent further submission

    final currentQuestion = questions[currentIndex];
    answers.add({
      "id": currentQuestion['id'],
      "question": currentQuestion['question'],
      "answer": answerText,
    });

    print("📝 Answer recorded: $answerText");

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _submitSurvey();
    }
  }

  Future<void> _submitSurvey() async {
    final payload = {
      "collegename": collegeName ?? "Unknown College",
      "answers": answers,
    };

    print("📤 POST /questions/answer payload:");
    print(json.encode(payload));

    try {
      final response = await http.post(
        Uri.parse("https://student-voice.onrender.com/api/questions/answer"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );

      print("📤 Headers: Authorization: Bearer $token, Content-Type: application/json");
      print("📥 Survey submission response: ${response.body}");

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() => _surveySubmitted = true);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Survey Submitted"),
            content: const Text("Thank you for completing the survey!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Submission failed")),
        );
      }
    } catch (e) {
      print("❌ Error submitting survey: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions available")),
      );
    }

    if (_surveySubmitted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Survey"),
          backgroundColor: Colors.indigo,
        ),
        body: const Center(
          child: Text("You have already submitted the survey."),
        ),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion['question'] ?? "No question text",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            if (currentQuestion['options'] != null &&
                currentQuestion['options'] is List<dynamic> &&
                (currentQuestion['options'] as List).isNotEmpty)
              ...List<Widget>.from(
                (currentQuestion['options'] as List<dynamic>).map<Widget>((option) {
                  final text = option['text'] ?? "No option";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () => _submitAnswer(text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(text, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }),
              )
            else
              SurveyTextInput(onSubmit: _submitAnswer),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your answer",
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSubmit(_controller.text.trim());
                _controller.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Submit"),
          ),
        ),
      ],
    );
  }
}
