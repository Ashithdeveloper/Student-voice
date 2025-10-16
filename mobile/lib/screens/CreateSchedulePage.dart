import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final TextEditingController courseController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  bool isLoading = false;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  /// Load token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    debugPrint("🔐 Loaded token: $token");
  }

  /// Send schedule details with token
  Future<void> createSchedule() async {
    final course = courseController.text.trim();
    final duration = durationController.text.trim();
    final language = languageController.text.trim();

    if (course.isEmpty || duration.isEmpty || language.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication token not found!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('https://student-voice.onrender.com/api/mentorchat/schedule');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ token added here
        },
        body: json.encode({
          "course": course,
          "duration": duration,
          "language": language,
        }),
      );

      debugPrint("📤 Schedule Sent: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Schedule Created Successfully!")),
        );
        Navigator.pop(context); // Go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error sending schedule: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating schedule")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Create Study Schedule"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: "Course you want to study",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: "Duration (e.g., 2 weeks, 1 month)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: languageController,
              decoration: const InputDecoration(
                labelText: "Preferred language",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : createSchedule,
              icon: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.save),
              label: const Text("Submit Schedule"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
