import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../User/info.dart';
import '../products.dart';
import 'calculator.dart';
import '../login.dart';
import 'user_profile.dart';
import 'my_orders.dart';

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

  void _openPage(int index) {
    if (index == _selectedIndex) return;
    
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SolarShopPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SolarCalculatorPage()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
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
              const SizedBox(height: 24),
              const Text(
                "Our Services",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.85,
                children: [
                  _serviceCard(
                    title: "SOLAR SHOP",
                    icon: Icons.shopping_bag_outlined,
                    iconColor: successGreen,
                    background: const Color(0xFFEAF8EE),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SolarShopPage())),
                    subtitle: "Buy panels, inverters & more",
                  ),
                  _serviceCard(
                    title: "SYSTEM CALCULATOR",
                    icon: Icons.calculate_outlined,
                    iconColor: solarYellow,
                    background: const Color(0xFFFFF4CC),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SolarCalculatorPage())),
                    subtitle: "Estimate your solar needs",
                  ),
                  _serviceCard(
                    title: "MY ORDERS",
                    icon: Icons.local_shipping_outlined,
                    iconColor: primaryBlue,
                    background: const Color(0xFFEAF3FB),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersPage())),
                    subtitle: "Track your purchases",
                  ),
                  _serviceCard(
                    title: "LEARN SOLAR",
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.deepPurple,
                    background: const Color(0xFFF3EAFB),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SolarInfoPage())),
                    subtitle: "Guides and information",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _userBottomNav(0),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: primaryBlue,
          child: Icon(Icons.person, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello,",
                style: TextStyle(
                  fontSize: 16,
                  color: darkGray.withOpacity(0.6),
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SolarShopPage())),
            icon: const Icon(Icons.shopping_cart_outlined, color: primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _serviceCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color background,
    required VoidCallback onTap,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderGray, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkGray,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: darkGray.withOpacity(0.6),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userBottomNav(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _openPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), activeIcon: Icon(Icons.calculate), label: 'Calc'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Global bottom navigation for users to reuse
Widget buildUserBottomNav(BuildContext context, int currentIndex) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoriesDashboard()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SolarShopPage()));
        if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SolarCalculatorPage()));
        if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
        if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), activeIcon: Icon(Icons.calculate), label: 'Calc'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}
