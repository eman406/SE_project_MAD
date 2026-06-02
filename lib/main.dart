import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:se_project/firebase_options.dart';
import 'package:se_project/splash.dart';
import 'package:se_project/Admin/Admin.dart';
import 'package:se_project/Admin/AdminUsers.dart';
import 'package:se_project/Admin/AdminWorker.dart';
import 'package:se_project/Admin/AdminQuotation.dart';
import 'package:se_project/Admin/AdminInstallation.dart';
import 'package:se_project/Admin/AdminProducts.dart'; 
import 'package:se_project/Admin/AdminOrders.dart';
import 'package:se_project/User/calculator.dart';
import 'package:se_project/User/WorkerRegister.dart';
import 'package:se_project/User/my_orders.dart';
import 'package:se_project/User/user_profile.dart';
import 'package:se_project/User/cart_page.dart';
import 'package:se_project/User/categories.dart';
import 'package:se_project/products.dart';
import 'package:se_project/Worker/workerDashboard.dart';
import 'package:se_project/firebase_test.dart';

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
        '/admin_orders': (context) => const AdminOrdersScreen(),
        '/worker_register': (context) => const WorkerRegisterScreen(),
        '/worker_dashboard': (context) => const WorkerDashboard(),
        '/calculator': (context) => const SolarCalculatorPage(),
        '/my_orders': (context) => const MyOrdersPage(),
        '/user_profile': (context) => const UserProfilePage(),
        '/cart': (context) => const CartPage(),
        '/shop': (context) => const SolarShopPage(),
        '/firebase_test': (context) => const FirebaseTestPage(),
      },
    );
  }
}
