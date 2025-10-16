import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final TextEditingController topicController = TextEditingController();
  bool isLoading = false;
  String? token;
  Map<String, dynamic>? scheduleData;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchSchedule();
  }

  Future<void> _loadTokenAndFetchSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await fetchExistingSchedule();
    }
  }

  Future<void> fetchExistingSchedule() async {
    try {
      final url = Uri.parse('https://student-voice.onrender.com/api/mentorchart/getschedule');
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        var scheduleMap = decoded['schedule'] ?? {};

        // Handle nested JSON in advice
        if ((scheduleMap['schedule'] == null || scheduleMap['schedule'].isEmpty) &&
            (scheduleMap['advice'] ?? "").startsWith("```json")) {
          try {
            final adviceJsonStr = scheduleMap['advice']
                .toString()
                .replaceAll("```json", "")
                .replaceAll("```", "")
                .trim();
            final adviceDecoded = json.decode(adviceJsonStr);
            scheduleMap = adviceDecoded;
          } catch (e) {
            debugPrint("❌ Error parsing nested advice JSON: $e");
          }
        }

        final List<dynamic> scheduleList =
        scheduleMap['schedule'] != null && scheduleMap['schedule'] is List
            ? scheduleMap['schedule']
            : [];

        setState(() {
          scheduleData = {
            "topic": scheduleMap['topic'] ?? "",
            "totalDays": scheduleMap['totalDays'] ?? 0,
            "schedule": scheduleList,
            "advice": scheduleMap['advice'] ?? ""
          };
        });
      } else {
        debugPrint("❌ Failed to fetch schedule: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception fetching schedule: $e");
    }
  }

  Uri? parseUrl(String url) {
    if (url.isEmpty) return null;
    if (!url.startsWith('http')) url = 'https://$url';
    try {
      return Uri.parse(url);
    } catch (_) {
      return null;
    }
  }

  Future<void> openLink(String link) async {
    final uri = parseUrl(link);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("❌ Could not launch link: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot launch this link")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid URL")),
      );
    }
  }

  Future<void> sendTopic() async {
    final topic = topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter a topic")));
      return;
    }
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Authentication token not found!")));
      return;
    }

    setState(() {
      isLoading = true;
      scheduleData = null;
    });

    try {
      final url = Uri.parse(
          'https://student-voice.onrender.com/api/mentorchart/schedule');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"topic": topic}),
      );

      final decoded = json.decode(response.body);
      var scheduleMap = decoded['schedule'] ?? {};

      // Parse nested JSON from advice if schedule empty
      if ((scheduleMap['schedule'] == null || scheduleMap['schedule'].isEmpty) &&
          (scheduleMap['advice'] ?? "").startsWith("```json")) {
        try {
          final adviceJsonStr = scheduleMap['advice']
              .toString()
              .replaceAll("```json", "")
              .replaceAll("```", "")
              .trim();
          final adviceDecoded = json.decode(adviceJsonStr);
          scheduleMap = adviceDecoded;
        } catch (e) {
          debugPrint("❌ Error parsing nested advice JSON: $e");
        }
      }

      final List<dynamic> scheduleList =
      scheduleMap['schedule'] != null && scheduleMap['schedule'] is List
          ? scheduleMap['schedule']
          : [];

      setState(() {
        scheduleData = {
          "topic": scheduleMap['topic'] ?? "",
          "totalDays": scheduleMap['totalDays'] ?? 0,
          "schedule": scheduleList,
          "advice": scheduleMap['advice'] ?? ""
        };
      });
    } catch (e) {
      debugPrint("❌ Error sending topic: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending topic")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildScheduleCard(Map<String, dynamic> dayData) {
    List<String> links = [];
    if (dayData['resources'] != null && dayData['resources'] is List) {
      for (var item in dayData['resources']) {
        if (item is String && item.isNotEmpty) links.add(item);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayData['day'] ?? 'Day',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (dayData['learningGoal'] != null)
              Text(dayData['learningGoal'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (dayData['details'] != null)
              Text(dayData['details'],
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            // Links
            ...links.map((link) => GestureDetector(
              onTap: () => openLink(link),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  link.contains("youtube.com") ? "▶ Watch Video" : link,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleList =
        (scheduleData?['schedule'] as List<dynamic>?) ?? <dynamic>[];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: topicController,
                decoration: InputDecoration(
                  hintText: "Enter topic...",
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.topic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isLoading ? null : sendTopic,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),
                label: const Text(
                  "Generate Schedule",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: scheduleList.isNotEmpty
                    ? ListView(
                  children: [
                    if ((scheduleData?['advice'] ?? "").isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "💡 Advice:\n${scheduleData!['advice']}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ...scheduleList
                        .map((day) =>
                        buildScheduleCard(day as Map<String, dynamic>))
                        .toList(),
                  ],
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.schedule,
                          size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Your schedule will appear here",
                        style: TextStyle(color: Colors.black54),
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
