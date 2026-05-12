import 'package:flutter/material.dart';
import 'categories.dart';
import 'products.dart';
import 'calculator.dart';

const Color primaryBlue = Color(0xFF1E3A5F);
const Color softGrey = Color(0xFF64748B);
const Color lightGrey = Color(0xFFE2E8F0);
const Color bgWhite = Color(0xFFF8FAFC);
const Color solarYellow = Color(0xFFFACC15);

class SolarInfoPage extends StatefulWidget {
  const SolarInfoPage({super.key});

  @override
  State<SolarInfoPage> createState() => _SolarInfoPageState();
}

class _SolarInfoPageState extends State<SolarInfoPage> {
  int index = 1;

  void _onTap(int i) {
    setState(() {
      index = i;
    });

    if (i == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CategoriesDashboard(),
        ),
      );
    }

    if (i == 1) {
      return;
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SolarShopPage(),
        ),
      );
    }

    if (i == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Page"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,

      body: Scrollbar(
        thickness: 6,
        radius: const Radius.circular(10),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(),
            const SizedBox(height: 20),

            _title("🌞 Introduction"),
            _card(
              "Solar energy is obtained from sunlight and converted into electricity using solar panels. It is renewable, clean, and reduces dependency on grid electricity.",
            ),

            _title("⚙️ How Solar System Works"),
            _card(
              "Sunlight → Solar Panels → DC Electricity → Inverter → AC Electricity → Home Usage",
            ),

            _title("🔋 Types of Solar Systems"),
            _bullet([
              "On-Grid System (Connected to WAPDA)",
              "Off-Grid System (Battery backup system)",
              "Hybrid System (Grid + Battery combined)",
            ]),

            _title("☀️ Types of Solar Panels"),
            _bullet([
              "Monocrystalline (High efficiency)",
              "Polycrystalline (Medium cost)",
              "Thin Film (Flexible panels)",
            ]),

            _title("⚡ Solar vs Load Shedding"),
            _compare(),

            _title("🌍 Advantages"),
            _bullet([
              "Low electricity bills",
              "Eco-friendly energy source",
              "Works during power cuts",
              "Long-term investment",
            ]),

            _title("⚠️ Disadvantages"),
            _bullet([
              "High installation cost",
              "Weather dependent",
              "Battery maintenance required",
            ]),

            const SizedBox(height: 20),
            _footer(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _onTap,
        selectedItemColor: primaryBlue,
        unselectedItemColor: softGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Info",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Calc",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        CircleAvatar(
          backgroundColor: solarYellow,
          child: Icon(Icons.solar_power, color: primaryBlue),
        ),
        Text(
          "Solar Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        Icon(Icons.menu, color: softGrey),
      ],
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _card(String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGrey),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: softGrey,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _bullet(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGrey),
      ),
      child: Column(
        children: items.map(
              (e) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "• ",
                style: TextStyle(
                  color: solarYellow,
                  fontSize: 18,
                ),
              ),
              Expanded(
                child: Text(
                  e,
                  style: const TextStyle(
                    color: softGrey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }

  Widget _compare() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGrey),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Solar Energy",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "✔ No load shedding\n✔ Low bills\n✔ Clean energy",
            style: TextStyle(color: softGrey),
          ),
          SizedBox(height: 10),
          Text(
            "Grid Electricity",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "✘ Load shedding\n✘ High bills\n✘ Dependency on WAPDA",
            style: TextStyle(color: softGrey),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: solarYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Solar energy is a long-term solution for Pakistan’s electricity problems and helps reduce load shedding impact.",
        style: TextStyle(color: primaryBlue),
      ),
    );
  }
}