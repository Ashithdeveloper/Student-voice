import 'package:flutter/material.dart';
import 'package:mobile/home/profilepage.dart';
import 'package:mobile/home/searchpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'communitypage.dart';
import 'homepage.dart';
import 'mentorpage.dart' show MentorTab;


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String? token;

  final List<Widget> _tabs = [
    const HomeTab(),
    const SearchTab(),
    const MentorTab(),
    const ProfileTab(),
    const CommunityTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Mentor"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
        ],
      ),
    );
  }
}
