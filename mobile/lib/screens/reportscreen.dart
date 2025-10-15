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
      print("⚠️ No token found");
    }
  }

  Future<void> _fetchReport() async {
    try {
      final url = "https://student-voice.onrender.com/api/questions/result/${Uri.encodeComponent(widget.collegeName)}";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📥 Report Data for ${widget.collegeName}: $data");

        setState(() {
          reportData = data['result']['results'];
          _isLoading = false;
        });
      } else {
        print("❌ Error fetching report: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Exception fetching report: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final double mental = (reportData!['mental_health'] as num).toDouble();
    final double placement = (reportData!['placement_training'] as num).toDouble();
    final double skill = (reportData!['skill_training'] as num).toDouble();
    final double total = (reportData!['total_score_college'] as num).toDouble();
    final overall = reportData!['overall_explanation'] ?? "No explanation available";

    final pieData = [
      ChartData("Mental", mental, Colors.blue),
      ChartData("Placement", placement, Colors.red),
      ChartData("Skill", skill, Colors.green),
    ];

    final barData = [
      ChartData("Mental", mental, Colors.blue),
      ChartData("Placement", placement, Colors.red),
      ChartData("Skill", skill, Colors.green),
      ChartData("Total", total, Colors.purple),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Report - ${widget.collegeName}"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie Chart
            const Text("Category Distribution (Pie Chart)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(isVisible: true),
                series: <PieSeries<ChartData, String>>[
                  PieSeries<ChartData, String>(
                    dataSource: pieData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    pointColorMapper: (ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart
            const Text("Category Comparison (Bar Chart)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(maximum: 100),
                series: <ColumnSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: barData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    pointColorMapper: (ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed Scores
            const Text("Detailed Scores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Mental Health Score: ${mental.toStringAsFixed(0)}"),
            Text("Placement Training Score: ${placement.toStringAsFixed(0)}"),
            Text("Skill Training Score: ${skill.toStringAsFixed(0)}"),
            Text("Total College Score: ${total.toStringAsFixed(0)}"),
            const SizedBox(height: 24),

            // Overall Explanation
            const Text("Overall Explanation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(overall),
          ],
        ),
      ),
    );
  }
}
