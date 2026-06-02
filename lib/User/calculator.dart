import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryBlue = Color(0xFF0F4C81);
const Color solarYellow = Color(0xFFFFC107);
const Color softWhite = Color(0xFFF8FAFC);
const Color darkGray = Color(0xFF1F2937);
const Color successGreen = Color(0xFF22C55E);
const Color borderGray = Color(0xFFE2E8F0);

class SolarCalculatorPage extends StatefulWidget {
  const SolarCalculatorPage({super.key});

  @override
  State<SolarCalculatorPage> createState() => _SolarCalculatorPageState();
}

class _SolarCalculatorPageState extends State<SolarCalculatorPage> {
  final Map<String, Map<String, dynamic>> _appliances = {
    'AC (1.5 Ton)': {'watts': 1800, 'count': 0, 'icon': Icons.ac_unit},
    'Refrigerator': {'watts': 300, 'count': 0, 'icon': Icons.kitchen},
    'Water Motor / Pump': {'watts': 750, 'count': 0, 'icon': Icons.water_drop},
    'Ceiling Fan': {'watts': 75, 'count': 0, 'icon': Icons.air},
    'LED Bulb': {'watts': 12, 'count': 0, 'icon': Icons.lightbulb_outline},
    'Washing Machine': {'watts': 500, 'count': 0, 'icon': Icons.local_laundry_service},
    'TV': {'watts': 100, 'count': 0, 'icon': Icons.tv},
  };

  double get _totalWatts {
    double total = 0;
    _appliances.forEach((key, value) {
      total += value['watts'] * value['count'];
    });
    return total;
  }

  double get _recommendedKW {
    // Basic calculation: total watts / 1000 * 1.2 (safety factor/efficiency)
    return (_totalWatts / 1000) * 1.2;
  }

  void _increment(String key) {
    setState(() {
      _appliances[key]!['count']++;
    });
  }

  void _decrement(String key) {
    setState(() {
      if (_appliances[key]!['count'] > 0) {
        _appliances[key]!['count']--;
      }
    });
  }

  // logic to fetch quotation from Firebase
  Future<void> _fetchAndShowQuotation() async {
    if (_totalWatts == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one appliance to generate a quote."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // LOGIC: Nearest higher KW
      int requiredKW = _recommendedKW.ceil();
      String docId = "${requiredKW}KW";

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quotations')
          .doc(docId)
          .get();

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        if (mounted) _displayOfficialQuotation(data);
      } else {
        if (mounted) {
          _showErrorDialog("No official quotation found for $requiredKW KW in our database. Please contact admin for a custom quote.");
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading indicator
      if (mounted) _showErrorDialog("Error fetching quotation: $e");
    }
  }

  void _displayOfficialQuotation(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Column(
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.green, size: 50),
              const SizedBox(height: 12),
              Text(
                "Official ${data['kw']} KW Quotation",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkGray),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildQuoteRow("Standard Price:", "Rs. ${data['price']}"),
                _buildQuoteRow("Solar Panels:", data['panels'] ?? "Standard Set"),
                _buildQuoteRow("Inverter:", data['inverter'] ?? "Standard Inverter"),
                if (data['battery'] != null && data['battery'].toString().isNotEmpty)
                  _buildQuoteRow("Battery:", data['battery']),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(thickness: 1),
                ),
                const Text(
                  "ADDITIONAL DETAILS:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  data['details'] ?? "Full system installation with warranty.",
                  style: const TextStyle(fontSize: 13, color: darkGray),
                ),
                const Divider(height: 32),
                const Text(
                  "Final Price (Estimated)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs. ${data['price']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: successGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Quote saved to your inquiry history!"), backgroundColor: successGreen),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SAVE QUOTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quotation Notice"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Widget _buildQuoteRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGray)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      appBar: AppBar(
        title: const Text(
          "System Calculator",
          style: TextStyle(color: darkGray, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appliances.length,
              itemBuilder: (context, index) {
                String key = _appliances.keys.elementAt(index);
                var data = _appliances[key]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(data['icon'], color: primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: darkGray,
                              ),
                            ),
                            Text(
                              "${data['watts']} Watts each",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildCountButton(
                            icon: Icons.remove,
                            onPressed: () => _decrement(key),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "${data['count']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                            ),
                          ),
                          _buildCountButton(
                            icon: Icons.add,
                            onPressed: () => _increment(key),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildCountButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: solarYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: darkGray),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Load:",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  "${_totalWatts.toStringAsFixed(0)} W",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recommended System:",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Estimated size with safety margin",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: solarYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_recommendedKW.toStringAsFixed(2)} kW",
                    style: const TextStyle(
                      color: darkGray,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _fetchAndShowQuotation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "GET DETAILED QUOTE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
