import 'package:flutter/material.dart';
import 'categories.dart';
import 'info.dart';
import 'calculator.dart';

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

  final List<Map> products = [
    {
      "name": "Monocrystalline Solar Panel",
      "price": "Rs 25,000",
      "icon": Icons.solar_power
    },
    {
      "name": "Polycrystalline Solar Panel",
      "price": "Rs 20,000",
      "icon": Icons.wb_sunny
    },
    {
      "name": "Hybrid Solar Panel Set",
      "price": "Rs 45,000",
      "icon": Icons.bolt
    },
    {"name": "AC Breaker 63A", "price": "Rs 5,000", "icon": Icons.power},
    {"name": "DC Breaker 63A", "price": "Rs 4,800", "icon": Icons.flash_on},
    {
      "name": "SPD Protection Device",
      "price": "Rs 5,500",
      "icon": Icons.shield
    },
    {"name": "MC4 Connector", "price": "Rs 800", "icon": Icons.cable},
    {
      "name": "AC Cable 6mm",
      "price": "Rs 250/m",
      "icon": Icons.electrical_services
    },
    {
      "name": "DC Cable 6mm",
      "price": "Rs 270/m",
      "icon": Icons.electrical_services
    },
    {"name": "Earthing Wire", "price": "Rs 1,200", "icon": Icons.terrain},
    {"name": "Changeover Switch", "price": "Rs 3,800", "icon": Icons.sync},
    {
      "name": "Battery Breaker",
      "price": "Rs 6,000",
      "icon": Icons.battery_charging_full
    },
  ];

  List<Map> get filtered {
    if (search.isEmpty) return products;
    return products
        .where((p) =>
        p["name"].toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

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
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: filtered.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, i) {
                  return _card(filtered[i]);
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.info), label: "Info"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: "Calc"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Shop"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: yellow,
            child: Icon(
              Icons.solar_power,
              color: primaryBlue,
            ),
          ),
          Text(
            "SOLAR SHOP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          Icon(
            Icons.shopping_cart,
            color: grey,
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: TextField(
          onChanged: (v) =>
              setState(() => search = v),
          decoration: const InputDecoration(
            icon: Icon(Icons.search,
                color: grey),
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

  Widget _card(Map item) {
    Color accent;

    if (item["name"].toLowerCase().contains("panel")) {
      accent = yellow;
    } else if (item["name"].toLowerCase().contains("breaker")) {
      accent = primaryBlue;
    } else if (item["name"].toLowerCase().contains("cable")) {
      accent = grey;
    } else {
      accent = Colors.green.shade300;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accent.withOpacity(0.06),
          ],
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
              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  primaryBlue.withOpacity(0.9),
                  grey.withOpacity(0.6),
                ],
              ),
            ),
            child: Image.network(
              _img(item["name"]),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(
                    item["icon"],
                    color: Colors.white,
                    size: 35,
                  ),
            ),
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"],
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item["price"],
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: grey,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "${item["name"]} added to cart",
                            ),
                            backgroundColor:
                            primaryBlue,
                          ),
                        );
                      },
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        yellow,
                        foregroundColor:
                        primaryBlue,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(8),
                        ),
                      ),
                      child: const Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
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