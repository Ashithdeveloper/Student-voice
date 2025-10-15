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

  bool _isObscure = true;

  Future<void> pickImage(bool isSelfie) async {
    final picker = ImagePicker();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "Create Student Account ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign up securely to access surveys and participate seamlessly",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildCard(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: collegeIdController,
                      label: "College ID",
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscure: _isObscure,
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(
                        title: "Upload College ID Card",
                        file: idCardImage,
                        onTap: () => pickImage(false)),
                    const SizedBox(height: 12),
                    _buildImagePicker(
                        title: "Take Live Selfie",
                        file: selfieImage,
                        onTap: () => pickImage(true)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Student Sign-Up Clicked")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select College",
        prefixIcon: const Icon(Icons.school_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: selectedCollege,
      isExpanded: true, // important for long text
      items: tamilNaduColleges
          .map((college) => DropdownMenuItem(
        value: college,
        child: Text(
          college,
          overflow: TextOverflow.ellipsis, // prevents overflow
        ),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedCollege = value;
        });
      },
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
          color: Colors.grey[50],
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
