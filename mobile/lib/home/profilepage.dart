import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login/login_select_page.dart';
import '../login/user_login.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? user;
  bool _isLoading = true;
  String? token;

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
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint("❌ Error fetching user: ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Error: $e");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginSelectionPage()), // Change to your login selection page
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.07; // responsive title

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.indigo),
        )
            : user == null
            ? const Center(
          child: Text(
            "No user data found",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top title text instead of AppBar
              Text(
                "My Profile",
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 25),

              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.indigo),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user!['name'] ?? "No Name",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user!['email'] ?? "No Email",
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user!['collegename'] ?? "No College",
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user,
                            color: Colors.indigo, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Role: ${user!['role'] ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified,
                            color: Colors.indigo, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          user!['isVerified'] == true
                              ? "Verified Account"
                              : "Not Verified",
                          style: TextStyle(
                            fontSize: 15,
                            color: user!['isVerified'] == true
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildInfoRow(Icons.person, "Full Name",
                        user!['name'] ?? "No Name"),
                    _buildInfoRow(Icons.email, "Email",
                        user!['email'] ?? "No Email"),
                    _buildInfoRow(Icons.school, "College",
                        user!['collegename'] ?? "No College"),
                    _buildInfoRow(Icons.assignment_ind, "Role",
                        user!['role'] ?? "N/A"),
                    _buildInfoRow(
                        Icons.verified,
                        "Verification",
                        user!['isVerified'] == true
                            ? "Verified"
                            : "Not Verified"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable info row widget
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.indigo, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54)),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
