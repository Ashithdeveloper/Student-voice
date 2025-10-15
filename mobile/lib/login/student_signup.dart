import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/login/student_login.dart';

class StudentSignupPage extends StatefulWidget {
  const StudentSignupPage({super.key});

  @override
  State<StudentSignupPage> createState() => _StudentSignupPageState();
}

class _StudentSignupPageState extends State<StudentSignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController collegeIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedCollege;
  File? idCardImage;
  File? selfieImage;

  final List<String> tamilNaduColleges = [
    "Anna University, Chennai",
    "PSG College of Technology, Coimbatore",
    "Coimbatore Institute of Technology",
    "SSN College of Engineering, Chennai",
    "Thiagarajar College of Engineering, Madurai",
    "Kumaraguru College of Technology, Coimbatore",
    "VIT University, Vellore",
    "SRM Institute of Science and Technology, Kattankulathur",
    "SASTRA University, Thanjavur",
    "Government College of Technology, Coimbatore",
  ];

  Future<void> pickImage(bool isSelfie) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: isSelfie ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isSelfie) {
          selfieImage = File(pickedFile.path);
        } else {
          idCardImage = File(pickedFile.path);
        }
      });
    }
  }

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Signup"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Create Student Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Full Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // College Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select College",
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedCollege,
              items: tamilNaduColleges
                  .map((college) =>
                  DropdownMenuItem(value: college, child: Text(college)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCollege = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // College ID
            TextField(
              controller: collegeIdController,
              decoration: InputDecoration(
                labelText: "College ID",
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ID Card Upload
            _buildImagePicker(
              title: "Upload College ID Card",
              file: idCardImage,
              onTap: () => pickImage(false),
            ),
            const SizedBox(height: 16),

            // Selfie Upload
            _buildImagePicker(
              title: "Take Live Selfie",
              file: selfieImage,
              onTap: () => pickImage(true),
            ),
            const SizedBox(height: 30),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Student Sign-Up Clicked")),
                  );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 🔙 Back to Login Text
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentLoginPage(),
                  ),
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: file == null ? Colors.grey : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file == null ? title : "Uploaded: ${file.path.split('/').last}",
                style: TextStyle(
                  color: file == null ? Colors.grey.shade700 : Colors.green,
                  fontWeight:
                  file == null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
