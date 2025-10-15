import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/reportscreen.dart';
import '../screens/surveyscreen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? user;
  bool _isLoading = true;
  String? token;
  bool surveyCompleted = false;

  List<Map<String, String>> fetchedColleges = []; // <-- only API data

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchUser();
  }

  Future<void> _loadTokenAndFetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await _fetchUser();
    } else {
      setState(() => _isLoading = false);
      print("⚠️ No token found");
    }
  }

  Future<void> _fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse("https://student-voice.onrender.com/api/user/getme"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          user = data['user'];
          surveyCompleted = data['user']['surveyCompleted'] ?? false;
          _isLoading = false;
        });
        await _fetchAnswers();
      } else {
        print("❌ Error fetching user: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => _isLoading = false);
    }
  }
  Future<void> _fetchAnswers() async {
    try {
      final response = await http.get(
        Uri.parse("https://student-voice.onrender.com/api/questions/allcollege"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("✅ Fetched Answers from API: $data"); // Check the console

        // Handle different possible formats
        if (data is List) {
          setState(() {
            fetchedColleges = data
                .map((e) {
              if (e is String) return {"name": e};
              if (e is Map && e.containsKey("name")) return {"name": e["name"]};
              return null;
            })
                .whereType<Map<String, String>>()
                .toList();
          });
        } else {
          print("❌ Unexpected API format for colleges");
        }
      } else {
        print("❌ Failed to fetch answers: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception fetching answers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your College Card
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your College",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?['collegename'] ?? "No College",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: surveyCompleted
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const SurveyPage()),
                          ).then((value) {
                            _fetchUser();
                          });
                        },
                        icon:
                        const Icon(Icons.edit, color: Colors.white),
                        label: Text(
                          surveyCompleted
                              ? "Survey Completed"
                              : "Enter Survey",
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surveyCompleted
                              ? Colors.grey
                              : Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (user?['collegename'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportPage(
                                    collegeName:
                                    user!['collegename']),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.pie_chart,
                            color: Colors.white),
                        label: const Text(
                          "View Report",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "All Colleges Reports",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fetchedColleges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    title: Text(
                      fetchedColleges[index]['name']!,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("View reports"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportPage(
                              collegeName:
                              fetchedColleges[index]['name']!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
