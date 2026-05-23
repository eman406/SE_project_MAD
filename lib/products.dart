import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'User/categories.dart';
import 'User/info.dart';
import 'User/calculator.dart';

const Color primaryBlue = Color(0xFF1E3A5F);
const Color grey = Color(0xFF64748B);
const Color bg = Color(0xFFF8FAFC);
const Color yellow = Color(0xFFFACC15);
const Color border = Color(0xFFE2E8F0);

class SolarShopPage extends StatefulWidget {
  const SolarShopPage({super.key});

  @override
  State<SolarShopPage> createState() => _SolarShopPageState();
}

class _SolarShopPageState extends State<SolarShopPage> {
  int index = 3;
  String search = "";
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');

  void _onTap(int i) {
    if (i == index) return;

    if (i == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CategoriesDashboard(),
        ),
      );
    }

    if (i == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SolarInfoPage(),
        ),
      );
    }

    if (i == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SolarCalculatorPage(),
        ),
      );
    }

    if (i == 3) {
      return;
    }

    if (i == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Page")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: productsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  
                  // Local filtering for search
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? "").toString().toLowerCase();
                    return name.contains(search.toLowerCase());
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredDocs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, i) {
                      final data = filteredDocs[i].data() as Map<String, dynamic>;
                      return _card(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _onTap,
        selectedItemColor: primaryBlue,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calc"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: yellow,
            child: Icon(Icons.solar_power, color: primaryBlue),
          ),
          Text(
            "SOLAR SHOP",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          Icon(Icons.shopping_cart, color: grey),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: grey),
            hintText: "Search products...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  String _img(String name) {
    if (name.toLowerCase().contains("panel")) {
      return "https://images.unsplash.com/photo-1509391366360-2e959784a276";
    } else if (name.toLowerCase().contains("breaker")) {
      return "https://images.unsplash.com/photo-1581091870622-3f5f2f0b3c3d";
    } else if (name.toLowerCase().contains("cable")) {
      return "https://images.unsplash.com/photo-1581090700227-1e8a3c1c3a3b";
    } else {
      return "https://images.unsplash.com/photo-1581092160562-40aa08e78837";
    }
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'battery': return Icons.battery_charging_full;
      case 'power': return Icons.power;
      case 'settings': return Icons.settings_input_component;
      default: return Icons.solar_power;
    }
  }

  Widget _card(Map data) {
    final name = data['name'] ?? "Product";
    final price = data['price'] ?? 0.0;
    final iconType = data['iconType'] ?? 'solar';
    
    Color accent;
    if (name.toLowerCase().contains("panel")) {
      accent = yellow;
    } else if (name.toLowerCase().contains("breaker")) {
      accent = primaryBlue;
    } else if (name.toLowerCase().contains("cable")) {
      accent = grey;
    } else {
      accent = Colors.green.shade300;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, accent.withOpacity(0.06)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [primaryBlue.withOpacity(0.9), grey.withOpacity(0.6)],
              ),
            ),
            child: Image.network(
              _img(name),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                _getIcon(iconType),
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rs ${price.toString()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: grey),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$name added to cart"),
                            backgroundColor: primaryBlue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("ADD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
