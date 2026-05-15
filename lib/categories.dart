import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'info.dart';
import 'products.dart';
import 'calculator.dart';
import 'login.dart';

const Color primaryBlue = Color(0xFF0F4C81);
const Color solarYellow = Color(0xFFFFC107);
const Color softWhite = Color(0xFFF8FAFC);
const Color darkGray = Color(0xFF1F2937);
const Color successGreen = Color(0xFF22C55E);
const Color borderGray = Color(0xFFE2E8F0);

class CategoriesDashboard extends StatefulWidget {
  const CategoriesDashboard({super.key});

  @override
  State<CategoriesDashboard> createState() => _CategoriesDashboardState();
}

class _CategoriesDashboardState extends State<CategoriesDashboard> {
  int _selectedIndex = 0;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            userName = doc.data()!['name'] ?? "User";
          });
        }
      } catch (e) {
        debugPrint("Error fetching user name: $e");
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _openPage(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarInfoPage()),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarCalculatorPage()),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarShopPage()),
      );
    }

    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Page")),
      );
    }
  }

  void _openCategory(String type) {
    if (type == "products") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarShopPage()),
      );
    }

    if (type == "info") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarInfoPage()),
      );
    }

    if (type == "calculator") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolarCalculatorPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              const Text(
                "Categories dashboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: _categoryCard(
                      title: "DASHBOARD",
                      icon: Icons.show_chart_rounded,
                      iconColor: primaryBlue,
                      background: const Color(0xFFEAF3FB),
                      borderColor: primaryBlue.withOpacity(0.25),
                      subtitle: "View Real-time\nData",
                      extraLines: const [
                        "Generation:   1.2 kWh",
                        "Consumption:  0.8 kWh",
                      ],
                      topRightIcon: Icons.wb_sunny_outlined,
                      topRightColor: solarYellow,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _openCategory("calculator"),
                    child: _categoryCard(
                      title: "SYSTEM\nCALCULATOR",
                      icon: Icons.calculate_outlined,
                      iconColor: Colors.black87,
                      background: const Color(0xFFFFF4CC),
                      borderColor: solarYellow.withOpacity(0.4),
                      subtitle: "Estimate Your\nSolar Potential",
                      topRightIcon: Icons.grid_view_rounded,
                      topRightColor: solarYellow,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _openCategory("products"),
                    child: _categoryCard(
                      title: "PRODUCTS",
                      icon: Icons.solar_power_rounded,
                      iconColor: successGreen,
                      background: const Color(0xFFEAF8EE),
                      borderColor: successGreen.withOpacity(0.3),
                      subtitle: "Explore New\nTech & Upgrades",
                      topRightIcon: Icons.shopping_cart_outlined,
                      topRightColor: successGreen,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _openCategory("info"),
                    child: _categoryCard(
                      title: "INFORMATION",
                      icon: Icons.info_outline_rounded,
                      iconColor: primaryBlue,
                      background: const Color(0xFFEAF7F9),
                      borderColor: primaryBlue.withOpacity(0.18),
                      subtitle: "Help, FAQs &\nGuides",
                      topRightIcon: Icons.description_outlined,
                      topRightColor: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _healthBar(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: borderGray,
          child: Icon(Icons.person, color: primaryBlue, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(
                  fontSize: 14,
                  color: darkGray.withOpacity(0.7),
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: darkGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Logout Button
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.red, size: 28),
          tooltip: "Logout",
        ),
      ],
    );
  }

  Widget _categoryCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color background,
    required Color borderColor,
    required String subtitle,
    List<String>? extraLines,
    IconData? topRightIcon,
    Color? topRightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                    height: 1.1,
                  ),
                ),
              ),
              if (topRightIcon != null)
                Icon(
                  topRightIcon,
                  size: 20,
                  color: topRightColor ?? primaryBlue,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 92,
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(icon, size: 66, color: iconColor),
            ),
          ),
          const SizedBox(height: 10),
          if (extraLines != null) ...[
            ...extraLines.map(
                  (line) => Text(
                line,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: darkGray,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: darkGray,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.battery_charging_full, color: successGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Row(
              children: [
                Text(
                  "System Health: ",
                  style: TextStyle(fontSize: 14, color: darkGray),
                ),
                Text(
                  "Optimal",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: successGreen,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 10,
            decoration: BoxDecoration(
              color: successGreen,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _openPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: successGreen,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Information',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
