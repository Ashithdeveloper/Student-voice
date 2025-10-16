import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  final String collegeName;
  const ReportPage({super.key, required this.collegeName});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class ChartData {
  final String category;
  final double value;
  final Color color;
  ChartData(this.category, this.value, this.color);
}

class _ReportPageState extends State<ReportPage> {
  Map<String, dynamic>? reportData;
  bool _isLoading = true;
  String? token;
  int studentCount = 0; // <-- Added to store student count

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchReport();
  }

  Future<void> _loadTokenAndFetchReport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token != null) {
      await _fetchReport();
    } else {
      setState(() => _isLoading = false);
      debugPrint("⚠️ No token found");
    }
  }

  Future<void> _fetchReport() async {
    try {
      final url =
          "https://student-voice.onrender.com/api/questions/result/${Uri.encodeComponent(widget.collegeName)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          reportData = data['result']['results'];
          studentCount = data['studentCount'] ?? 0; // <-- fetch student count
          _isLoading = false;
        });

        debugPrint("✅ Report Data: $reportData");
        debugPrint("📊 Student Count: $studentCount");
      } else {
        debugPrint("❌ Error fetching report: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Exception fetching report: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.055;
    final sectionFontSize = screenWidth * 0.04;
    final contentFontSize = screenWidth * 0.035;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (reportData == null) {
      return const Scaffold(
        body: Center(child: Text("No report available")),
      );
    }

    // Extract report data
    final double mental = (reportData!['mental_health'] as num).toDouble();
    final double placement =
    (reportData!['placement_training'] as num).toDouble();
    final double skill = (reportData!['skill_training'] as num).toDouble();
    final double total = (reportData!['total_score_college'] as num).toDouble();
    final overall = reportData!['overall_explanation'] ?? "No explanation available";

    // Chart colors
    final chartColors = [
      Colors.lightBlueAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
    ];

    final pieData = [
      ChartData("Mental", mental, chartColors[0]),
      ChartData("Placement", placement, chartColors[1]),
      ChartData("Skill", skill, chartColors[2]),
    ];

    final barData = [
      ChartData("Mental", mental, chartColors[0]),
      ChartData("Placement", placement, chartColors[1]),
      ChartData("Skill", skill, chartColors[2]),
      ChartData("Total", total, chartColors[3]),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College Card with Student Count
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: Colors.indigo, width: 5),
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.collegeName,
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "College Survey Overview",
                        style: TextStyle(
                            fontSize: contentFontSize,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Students Surveyed: $studentCount", // <-- student count displayed
                        style: TextStyle(
                            fontSize: contentFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pie Chart
              Text(
                "Category Distribution",
                style: TextStyle(
                    fontSize: sectionFontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: SfCircularChart(
                  legend:
                  Legend(isVisible: true, position: LegendPosition.bottom),
                  series: <PieSeries<ChartData, String>>[
                    PieSeries<ChartData, String>(
                      dataSource: pieData,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      pointColorMapper: (ChartData data, _) => data.color,
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bar Chart
              Text(
                "Category Comparison",
                style: TextStyle(
                    fontSize: sectionFontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(maximum: 100),
                  series: <ColumnSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: barData,
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      pointColorMapper: (ChartData data, _) => data.color,
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Score Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _scoreCard("Mental", mental.toStringAsFixed(0), chartColors[0]),
                  _scoreCard(
                      "Placement", placement.toStringAsFixed(0), chartColors[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _scoreCard("Skill", skill.toStringAsFixed(0), chartColors[2]),
                  _scoreCard("Total", total.toStringAsFixed(0), chartColors[3]),
                ],
              ),

              const SizedBox(height: 20),

              // Overall Explanation Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: Colors.indigo, width: 5),
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Overall Explanation",
                        style: TextStyle(
                            fontSize: sectionFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      const SizedBox(height: 12),
                      Text(overall, style: TextStyle(fontSize: contentFontSize)),
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

  // Helper for score card
  Widget _scoreCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
