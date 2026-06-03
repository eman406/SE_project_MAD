import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminQuotationScreen extends StatefulWidget {
  const AdminQuotationScreen({super.key});

  @override
  State<AdminQuotationScreen> createState() => _AdminQuotationScreenState();
}

class _AdminQuotationScreenState extends State<AdminQuotationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logic to update or add price packages (the data used by the calculator)
  void _updatePackage(String kw, String price, String panels, String inverter) async {
    if (kw.isEmpty || price.isEmpty) return;
    try {
      await _firestore.collection('quotations').doc("${kw}KW").set({
        'kw': kw,
        'price': int.parse(price),
        'panels': panels,
        'inverter': inverter,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Price Package Updated"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error updating package: $e");
    }
  }

  void _deletePackage(String id) async {
    await _firestore.collection('quotations').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin_dashboard'),
        ),
        title: const Text("Manage Quotation", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('quotations').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("No Pricing Packages Defined."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1E3A5F),
                          child: Icon(Icons.calculate, color: Colors.white, size: 20),
                        ),
                        title: Text("${data['kw']} KW System", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Price: Rs. ${data['price']}\nPanels: ${data['panels']}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPackageDialog(data: data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deletePackage(docs[index].id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPackageDialog(),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New Price", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showPackageDialog({Map<String, dynamic>? data}) {
    final kwCtrl = TextEditingController(text: data?['kw']?.toString());
    final priceCtrl = TextEditingController(text: data?['price']?.toString());
    final panelCtrl = TextEditingController(text: data?['panels']);
    final invCtrl = TextEditingController(text: data?['inverter']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(data == null ? "Define New System Price" : "Edit System Price"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kwCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "System Size (KW)", hintText: "e.g. 1"),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Total Price (Rs.)", hintText: "e.g. 150000"),
              ),
              TextField(
                controller: panelCtrl,
                decoration: const InputDecoration(labelText: "Panels Detail", hintText: "e.g. 540W x 2"),
              ),
              TextField(
                controller: invCtrl,
                decoration: const InputDecoration(labelText: "Inverter Detail", hintText: "e.g. 1.2KW Hybrid"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _updatePackage(kwCtrl.text, priceCtrl.text, panelCtrl.text, invCtrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
            child: const Text("Save Package", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
