import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup.dart';
import 'User/categories.dart';
import 'Admin/Admin.dart';
import 'Worker/workerDashboard.dart'; // Added Import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color primaryBlue = const Color(0xFF1E3A5F);
  final Color slateGrey = const Color(0xFF64748B);
  final Color solarYellow = const Color(0xFFFFC107);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color darkGray = const Color(0xFF1F2937);

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Admin bypass check
      if (_emailController.text.trim() == "admin@gmail.com" && _passwordController.text.trim() == "admin123") {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
        }
        return;
      }

      // 2. Auth Sign In
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 3. Worker Approval Check
      // Check if user is in pending requests
      DocumentSnapshot pendingDoc = await FirebaseFirestore.instance.collection('pending_workers').doc(uid).get();
      if (pendingDoc.exists) {
        await FirebaseAuth.instance.signOut();
        _showError("Aapki request pending hai. Please admin ke approval ka intezar karein.");
        return;
      }

      // 4. Check for Approved Worker or Normal User
      DocumentSnapshot workerDoc = await FirebaseFirestore.instance.collection('approved_workers').doc(uid).get();
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (mounted) {
        if (workerDoc.exists) {
          // If it's an approved worker, show WorkerDashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WorkerDashboard()));
        } else if (userDoc.exists) {
          // If it's a normal user, show CategoriesDashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CategoriesDashboard()));
        } else {
          // If they are authenticated but no record exists in users or approved_workers collection
          await FirebaseAuth.instance.signOut();
          _showError("Account data not found. Contact Admin.");
        }
      }

    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login Failed");
    } catch (e) {
      _showError("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: slateGrey),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryBlue, slateGrey, softWhite], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Icon(Icons.solar_power_rounded, size: 70, color: solarYellow),
                  const Text("SMART ENGINEERING", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        color: Colors.white.withValues(alpha: 0.3),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 25),
                              TextFormField(controller: _emailController, decoration: inputDecoration("Email", Icons.email_outlined)),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: inputDecoration("Password", Icons.lock_outline).copyWith(
                                  suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _isLoading 
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(backgroundColor: solarYellow, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                                    child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                  ),
                              const SizedBox(height: 20),
                              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())), child: const Text("Don't have an account? Sign Up")),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
