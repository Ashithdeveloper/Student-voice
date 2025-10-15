import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import '../home/homepage.dart';
import '../home/mainpage.dart';
import 'student_login.dart';

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

  bool _isObscure = true;
  bool _isLoading = false;

  final List<String> tamilNaduColleges = [
    "Anna University, Chennai",
    "PSG College of Technology, Coimbatore",
    "Coimbatore Institute of Technology",
    "Mount Zion college of Engineering and Technology"
    "SSN College of Engineering, Tiruchirapalli",
    "Thiagarajar College of Engineering, Madurai",
    "Kumaraguru College of Technology, Coimbatore",
    "Mar Ephraem College of Engineering and Technology",
    "VIT University, Vellore",
    "SRM Institute of Science and Technology, Kattankulathur",
    "SASTRA University, Thanjavur",
    "Government College of Technology, Coimbatore",
  ];

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

  Future<void> signUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        collegeIdController.text.isEmpty ||
        selectedCollege == null ||
        idCardImage == null ||
        selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and upload images")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    final uri = Uri.parse("https://student-voice.onrender.com/api/user/signup");
    var request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['name'] = nameController.text.trim();
    request.fields['email'] = emailController.text.trim();
    request.fields['password'] = passwordController.text.trim();
    request.fields['collegeId'] = collegeIdController.text.trim();
    request.fields['collegename'] = selectedCollege!;

    // Read files as bytes and add with explicit content type
    final idCardBytes = await idCardImage!.readAsBytes();
    final selfieBytes = await selfieImage!.readAsBytes();

    print("📤 ID Card size: ${idCardBytes.length} bytes");
    print("📤 Selfie size: ${selfieBytes.length} bytes");

    request.files.add(http.MultipartFile.fromBytes(
      'idCard',
      idCardBytes,
      filename: 'idCard.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));

    request.files.add(http.MultipartFile.fromBytes(
      'liveselfie',
      selfieBytes,
      filename: 'selfie.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));

    // Logging for debug
    print("\n============================");
    print("📤 Sending Signup Request...");
    print("============================");
    print("➡️ URL: $uri");
    print("➡️ Method: POST (multipart/form-data)");
    print("➡️ Fields:");
    request.fields.forEach((key, value) {
      print("   $key: $value");
    });
    print("➡️ Files:");
    for (var file in request.files) {
      print("   ${file.field}: ${file.filename} (${file.length} bytes, type: ${file.contentType})");
    }
    print("============================\n");

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      setState(() {
        _isLoading = false; // Stop loading
      });

      // Logging response
      print("📥 Response Received:");
      print("➡️ Status Code: ${response.statusCode}");
      print("➡️ Response Body: $responseBody");
      print("============================\n");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        final token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        final data = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Signup failed')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("❌ Error during signup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
                "Create Student Account",
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
                      onTap: () => pickImage(false),
                    ),
                    const SizedBox(height: 12),
                    _buildImagePicker(
                      title: "Take Live Selfie",
                      file: selfieImage,
                      onTap: () => pickImage(true),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Signing Up...",
                                style: TextStyle(fontSize: 18)),
                          ],
                        )
                            : const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
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
              ),
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: selectedCollege,
      isExpanded: true,
      items: tamilNaduColleges
          .map((college) => DropdownMenuItem(
        value: college,
        child: Text(
          college,
          overflow: TextOverflow.ellipsis,
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
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
