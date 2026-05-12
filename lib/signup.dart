import 'dart:ui';
import 'package:flutter/material.dart';
import 'categories.dart';

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

  /// ROLE
  String _selectedRole = "User";

  /// CONTROLLERS
  final TextEditingController _nameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();
  final TextEditingController _confirmController =
  TextEditingController();
  final TextEditingController _phoneController =
  TextEditingController();

  /// COLORS
  final Color primaryBlue = const Color(0xFF0F4C81);
  final Color solarYellow = const Color(0xFFFFC107);
  final Color darkGray = const Color(0xFF1F2937);
  final Color successGreen = const Color(0xFF22C55E);

  /// VALIDATION FLAGS
  bool _nameValid = false;
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _confirmValid = false;
  bool _phoneValid = false;

  /// LIVE VALIDATION
  void _validateFields() {
    setState(() {
      _nameValid =
          _nameController.text.trim().length >= 3;

      _emailValid = RegExp(r"^[^@]+@[^@]+\.[^@]+")
          .hasMatch(_emailController.text.trim());

      _passwordValid =
          _passwordController.text.length >= 6;

      _confirmValid =
          _confirmController.text ==
              _passwordController.text &&
              _confirmController.text.isNotEmpty;

      /// PHONE: EXACT 11 DIGITS
      _phoneValid = RegExp(r'^[0-9]{11}$')
          .hasMatch(_phoneController.text.trim());
    });
  }

  /// REGISTER
  void _handleRegister() {
    _validateFields();

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Please accept Terms & Privacy Policy"),
        ),
      );
      return;
    }

    if (_nameValid &&
        _emailValid &&
        _passwordValid &&
        _confirmValid &&
        _phoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successGreen,
          content: Text(
            "Registration Successful as $_selectedRole!",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix all errors"),
        ),
      );
    }
  }

  /// INPUT DECORATION
  InputDecoration _input(
      String label, IconData icon, bool valid) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: valid ? successGreen : solarYellow,
          width: 2,
        ),
      ),
      suffixIcon: Icon(
        valid ? Icons.check_circle : Icons.info_outline,
        color: valid ? successGreen : Colors.grey,
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F4C81),
                  Color(0xFFF8FAFC),
                ],
              ),
            ),
          ),

          /// DECORATIONS
          Positioned(
            top: -80,
            right: -50,
            child: _circle(
              220,
              solarYellow.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _circle(
              260,
              Colors.white.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Icon(
                    Icons.solar_power_rounded,
                    size: 70,
                    color: solarYellow,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "CREATE ACCOUNT",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// GLASS CARD
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.25),
                          borderRadius:
                          BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            /// NAME
                            TextField(
                              controller: _nameController,
                              onChanged: (_) =>
                                  _validateFields(),
                              decoration: _input(
                                "Full Name",
                                Icons.person,
                                _nameValid,
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// EMAIL
                            TextField(
                              controller:
                              _emailController,
                              onChanged: (_) =>
                                  _validateFields(),
                              decoration: _input(
                                "Email",
                                Icons.email,
                                _emailValid,
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// PHONE
                            TextField(
                              controller:
                              _phoneController,
                              keyboardType:
                              TextInputType.phone,
                              onChanged: (_) =>
                                  _validateFields(),
                              decoration: _input(
                                "Phone Number",
                                Icons.phone_android,
                                _phoneValid,
                              ).copyWith(
                                hintText: "03XXXXXXXXX",
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// ROLE DROPDOWN
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: "Select Role",
                                prefixIcon: Icon(
                                  Icons.work,
                                  color: primaryBlue,
                                ),
                                filled: true,
                                fillColor: Colors.white
                                    .withValues(alpha: 0.85),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(18),
                                  borderSide:
                                  BorderSide.none,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "User",
                                  child: Text("User"),
                                ),
                                DropdownMenuItem(
                                  value: "Worker",
                                  child: Text("Worker"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole =
                                  value!;
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            /// PASSWORD
                            TextField(
                              controller:
                              _passwordController,
                              obscureText:
                              _obscurePassword,
                              onChanged: (_) =>
                                  _validateFields(),
                              decoration: _input(
                                "Password",
                                Icons.lock,
                                _passwordValid,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons
                                        .visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// CONFIRM PASSWORD
                            TextField(
                              controller:
                              _confirmController,
                              obscureText:
                              _obscureConfirmPassword,
                              onChanged: (_) =>
                                  _validateFields(),
                              decoration: _input(
                                "Confirm Password",
                                Icons.verified,
                                _confirmValid,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons
                                        .visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Checkbox(
                                  value: _agreed,
                                  onChanged: (v) {
                                    setState(() {
                                      _agreed = v!;
                                    });
                                  },
                                  activeColor:
                                  primaryBlue,
                                ),
                                const Expanded(
                                  child: Text(
                                    "I agree to Terms & Privacy Policy",
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  solarYellow,
                                  foregroundColor:
                                  darkGray,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        18),
                                  ),
                                ),
                                onPressed: () {
                                  _handleRegister();

                                  /// NAVIGATION
                                  if (_nameValid &&
                                      _emailValid &&
                                      _passwordValid &&
                                      _confirmValid &&
                                      _phoneValid &&
                                      _agreed) {
                                    Navigator
                                        .pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                        const CategoriesDashboard(),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "REGISTER",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
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