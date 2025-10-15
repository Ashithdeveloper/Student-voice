import 'package:flutter/material.dart';
import 'package:mobile/home/mainpage.dart';
import 'package:mobile/login/login_select_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/user_login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    await Future.delayed(const Duration(seconds: 2)); // Optional splash delay

    if (mounted) {
      if (token != null) {
        // Navigate to Home if token exists
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        // Navigate to Login if no token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginSelectionPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Checking Authentication...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}
