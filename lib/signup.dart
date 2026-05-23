import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'User/categories.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreed = false;
  bool _isLoading = false;

  /// ROLE
  String _selectedRole = "User";

  /// CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  /// COLORS
  final Color primaryBlue = const Color(0xFF0F4C81);
  final Color solarYellow = const Color(0xFFFFC107);
  final Color darkGray = const Color(0xFF1F2937);
  final Color successGreen = const Color(0xFF22C55E);

  /// REGISTER LOGIC
  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    if (!_agreed) {
      _showSnackBar("Please accept Terms & Privacy Policy");
      return;
    }

    if (name.length < 3 || email.isEmpty || password.length < 6 || phone.length != 11) {
      _showSnackBar("Please fill all fields correctly");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create User in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      if (_selectedRole == "Worker") {
        // 2a. Save to pending_workers if role is Worker
        await FirebaseFirestore.instance.collection('pending_workers').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'Worker',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sign out immediately so they can't access the app yet
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          _showStatusDialog("Aapki request submit ho chuki hai. Please wait jab tak admin aapko approve nahi karta.");
        }
      } else {
        // 2b. Save to users collection if regular User
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'User',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          _showSnackBar("Registration Successful!", isError: false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesDashboard()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Registration Failed");
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showStatusDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Request Submitted"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : successGreen,
      ),
    );
  }

  /// INPUT DECORATION
  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F4C81), Color(0xFFF8FAFC)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.solar_power_rounded, size: 70, color: solarYellow),
                  const Text("CREATE ACCOUNT",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            TextField(controller: _nameController, decoration: _input("Full Name", Icons.person)),
                            const SizedBox(height: 15),
                            TextField(controller: _emailController, decoration: _input("Email", Icons.email)),
                            const SizedBox(height: 15),
                            TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _input("Phone Number", Icons.phone_android).copyWith(hintText: "03XXXXXXXXX")),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: _input("Select Role", Icons.work),
                              items: const [
                                DropdownMenuItem(value: "User", child: Text("User")),
                                DropdownMenuItem(value: "Worker", child: Text("Worker")),
                              ],
                              onChanged: (v) => setState(() => _selectedRole = v!),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: _input("Password", Icons.lock).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _confirmController,
                              obscureText: _obscureConfirmPassword,
                              decoration: _input("Confirm Password", Icons.verified).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v!), activeColor: primaryBlue),
                                const Expanded(child: Text("I agree to Terms & Privacy Policy")),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: solarYellow,
                                  foregroundColor: darkGray,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: _isLoading ? null : _handleRegister,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
