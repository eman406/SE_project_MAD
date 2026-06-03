import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return (_totalWatts / 1000);
  }

  void _increment(String key) {
    setState(() => _appliances[key]!['count']++);
  }

  void _decrement(String key) {
    setState(() {
      if (_appliances[key]!['count'] > 0) _appliances[key]!['count']--;
    });
  }

  Future<void> _fetchAndShowQuotation() async {
    if (_totalWatts == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add appliances.")));
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      int requiredKW = _recommendedKW.ceil();
      if (requiredKW == 0) requiredKW = 1;
      String docId = "${requiredKW}KW";

      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('quotations').doc(docId).get();
      if (mounted) Navigator.pop(context);

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        if (mounted) _displayOfficialQuotation(data);
      } else {
        if (mounted) _showErrorDialog("No official quotation found for $requiredKW KW.");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _displayOfficialQuotation(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Official ${data['kw']} KW Quotation", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Price: Rs. ${data['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: successGreen)),
            const SizedBox(height: 10),
            Text("Panels: ${data['panels']}"),
            Text("Inverter: ${data['inverter']}"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _handleQuotationResponse(data, 'Accepted'),
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            child: const Text("ACCEPT"),
          ),
          OutlinedButton(
            onPressed: () => _handleQuotationResponse(data, 'REJECT'),
            child: const Text("REJECT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuotationResponse(Map<String, dynamic> quoteData, String status) async {
    Navigator.pop(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String userName = userDoc.exists ? (userDoc.data() as Map)['name'] ?? 'User' : 'User';
      String userPhone = userDoc.exists ? (userDoc.data() as Map)['phone'] ?? 'N/A' : 'N/A';

      if (status == 'Accepted') {
        // Direct logic: Save to installations collection as requested
        await FirebaseFirestore.instance.collection('installations').add({
          'userId': user.uid,
          'userName': userName,
          'userPhone': userPhone,
          'systemSize': "${quoteData['kw']} KW",
          'amount': (quoteData['price'] ?? 0).toDouble(),
          'status': 'Pending Assignment',
          'requestDate': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          _showSuccessDialog("Quotation Accepted! Your request has been sent to Admin for installation assignment.");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quotation Rejected.")));
        }
      }
    } catch (e) {
      _showErrorDialog("Error: $e");
    }
  }

  void _showSuccessDialog(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Notice"), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  void _showErrorDialog(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Error"), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/user_home'),
        ),
        title: const Text("System Calculator", style: TextStyle(color: darkGray, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(data['icon'], color: primaryBlue),
                    title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${data['watts']} Watts"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => _decrement(key), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                        Text("${data['count']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () => _increment(key), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                      ],
                    ),
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Load:", style: TextStyle(color: Colors.white70)), Text("${_totalWatts.toStringAsFixed(0)} W", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Recommended:", style: TextStyle(color: Colors.white70)), Text("${_recommendedKW.toStringAsFixed(2)} kW", style: const TextStyle(color: solarYellow, fontSize: 20, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _fetchAndShowQuotation, style: ElevatedButton.styleFrom(backgroundColor: successGreen), child: const Text("GET DETAILED QUOTE", style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}
