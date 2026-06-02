import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash.dart';
import 'Admin/Admin.dart';
import 'Admin/AdminUsers.dart';
import 'Admin/AdminWorker.dart';
import 'Admin/AdminQuotation.dart';
import 'Admin/AdminInstallation.dart';
import 'Admin/AdminProducts.dart'; 
import 'User/calculator.dart';
import 'User/WorkerRegister.dart';
import 'Worker/workerDashboard.dart';
import 'firebase_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/admin_products': (context) => const AdminProductManagement(),
        '/admin_users': (context) => const AdminUsersScreen(),
        '/admin_workers': (context) => const AdminWorkerScreen(),
        '/admin_quotations': (context) => const AdminQuotationScreen(),
        '/admin_installations': (context) => const AdminInstallationScreen(),
        '/worker_register': (context) => const WorkerRegisterScreen(),
        '/worker_dashboard': (context) => const WorkerDashboard(),
        '/calculator': (context) => const SolarCalculatorPage(),
        '/firebase_test': (context) => const FirebaseTestPage(),
      },
    );
  }
}
