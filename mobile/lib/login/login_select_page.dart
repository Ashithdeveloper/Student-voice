import 'package:flutter/material.dart';
import 'package:mobile/login/student_login.dart';
import 'package:mobile/login/user_login.dart';

class LoginSelectionPage extends StatefulWidget {
  const LoginSelectionPage({super.key});

  @override
  State<LoginSelectionPage> createState() => _LoginSelectionPageState();
}

class _LoginSelectionPageState extends State<LoginSelectionPage> {
  int _currentPage = 0; // 0 = Student, 1 = User

  void _switchPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "Welcome to Student's Voice ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Login securely to continue your journey",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Toggle buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == 0
                            ? Colors.indigo
                            : Colors.grey[300],
                        foregroundColor:
                        _currentPage == 0 ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _switchPage(0),
                      child: const Text(
                        "Student",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == 1
                            ? Colors.teal
                            : Colors.grey[300],
                        foregroundColor:
                        _currentPage == 1 ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _switchPage(1),
                      child: const Text(
                        "User",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Card that switches
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _currentPage == 0
                    ? _buildCard(
                  context,
                  key: const ValueKey("student"),
                  icon: Icons.school_outlined,
                  title: "Student Login",
                  description:
                  "Access surveys, verify your identity, and participate seamlessly.",
                  points: const [
                    "🔒 Secure ID verification",
                    "📊 Access exclusive surveys",
                    "🛡️ Protected student data",
                  ],
                  buttonText: "Continue as Student",
                  buttonColor: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentLoginPage(),
                      ),
                    );
                  },
                )
                    : _buildCard(
                  context,
                  key: const ValueKey("user"),
                  icon: Icons.person_outline,
                  title: "User Login",
                  description:
                  "Participate in surveys, view analytics, and track your activity.",
                  points: const [
                    "📝 Take part in surveys",
                    "📈 View results & insights",
                    "👤 Personalized experience",
                  ],
                  buttonText: "Continue as User",
                  buttonColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required Key key,
        required IconData icon,
        required String title,
        required String description,
        required List<String> points,
        required String buttonText,
        required Color buttonColor,
        required VoidCallback onTap,
      }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              buttonColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: buttonColor.withOpacity(0.12),
              child: Icon(icon, color: buttonColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points
                  .map((point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
                  point,
                  style: const TextStyle(fontSize: 14),
                ),
              ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                ),
                onPressed: onTap,
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
