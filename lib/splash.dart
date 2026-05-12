import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _Splash2State();
}

class _Splash2State extends State<Splash2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sunAnimation;
  late Animation<double> _fadeAnimation;

  final Color primaryBlue = const Color(0xFF0F4C81);
  final Color solarYellow = const Color(0xFFFFC107);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color darkGray = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _sunAnimation = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCloud(double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.cloud,
        size: 55,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }

  Widget buildBird(double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.flutter_dash,
        size: 20,
        color: Colors.white.withValues(alpha: 0.45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Sky gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryBlue,
                  primaryBlue.withValues(alpha: 0.85),
                  solarYellow.withValues(alpha: 0.35),
                  softWhite,
                ],
              ),
            ),
          ),

          /// Clouds
          buildCloud(90, 40),
          buildCloud(140, 260),
          buildCloud(210, 110),

          /// Birds
          buildBird(100, 170),
          buildBird(130, 210),

          /// Sun
          AnimatedBuilder(
            animation: _sunAnimation,
            builder: (_, child) {
              return Positioned(
                top: 150 + _sunAnimation.value,
                left: MediaQuery.of(context).size.width / 2 - 60,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: solarYellow,
                    boxShadow: [
                      BoxShadow(
                        color: solarYellow.withValues(alpha: 0.6),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// Ground / Home Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(60),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// House icon
                  Positioned(
                    top: 40,
                    child: Icon(
                      Icons.home_rounded,
                      size: 110,
                      color: Colors.white,
                    ),
                  ),

                  /// Solar panel icon
                  Positioned(
                    top: 105,
                    child: Icon(
                      Icons.solar_power_rounded,
                      size: 45,
                      color: solarYellow,
                    ),
                  ),

                  /// Branding
                  Positioned(
                    bottom: 75,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "SMART ENGINEERING",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 48,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Clean Energy. Smart Living.",
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 18,
                    child: SizedBox(
                      width: 170,
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        borderRadius:
                        BorderRadius.circular(10),
                        backgroundColor:
                        Colors.white.withValues(
                          alpha: 0.2,
                        ),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          solarYellow,
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