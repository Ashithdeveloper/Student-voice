import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();

  List<String> allColleges = [
    "Anna University Chennai",
    "MIT College of Engineering",
    "IIT Madras",
    "VIT Vellore",
    "SRM Institute of Science",
  ];

  List<String> suggestedColleges = [];

  @override
  void initState() {
    super.initState();
    suggestedColleges = allColleges; // initially show all
  }

  void _searchCollege(String query) {
    final suggestions = allColleges
        .where((college) =>
        college.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      suggestedColleges = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.07; // responsive title

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title instead of AppBar
              Center(
                child: Text(
                  "Search Colleges",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchCollege,
                  decoration: const InputDecoration(
                    hintText: "Search colleges...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Suggested Colleges
              Expanded(
                child: suggestedColleges.isEmpty
                    ? const Center(
                  child: Text(
                    "No colleges found",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: suggestedColleges.length,
                  itemBuilder: (context, index) {
                    final college = suggestedColleges[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          college,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: const Text(
                            "Survey Score: 85, Placement: 90, Skill: 88"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.indigo),
                        onTap: () {
                          // Navigate to report page
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
