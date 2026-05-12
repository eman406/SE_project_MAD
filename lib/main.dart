import 'package:flutter/material.dart';
import 'splash.dart';
import 'Admin.dart';
import 'AdminProducts.dart';

void main() {
  runApp(const SmartEngineeringApp());
}

class SmartEngineeringApp extends StatelessWidget {
  const SmartEngineeringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Engineering',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const Splash2(),
      routes: {
        '/admin_login': (context) => const LoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/admin_products': (context) => const AdminProductManagement(),
      },
    );
  }
}
