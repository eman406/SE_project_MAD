import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductManagement extends StatefulWidget {
  const AdminProductManagement({super.key});

  @override
  State<AdminProductManagement> createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final specController = TextEditingController();
    final priceController = TextEditingController();
    final unitsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Product"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name (e.g. Panel)")),
              TextField(controller: specController, decoration: const InputDecoration(labelText: "Specs (e.g. 540W)")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price (Rs)"), keyboardType: TextInputType.number),
              TextField(controller: unitsController, decoration: const InputDecoration(labelText: "Stock Units"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                await _firestore.collection('products').add({
                  'name': nameController.text.toUpperCase(),
                  'spec': specController.text.toUpperCase(),
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'units': int.tryParse(unitsController.text) ?? 0,
                  'status': 'Active',
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _updatePrice(String id, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Price"),
        content: TextField(controller: controller, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double? newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                await _firestore.collection('products').doc(id).update({'price': newPrice});
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("Product Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const Center(child: Text("Error loading products"));
                
                var docs = snapshot.data!.docs.where((d) {
                  var data = d.data() as Map<String, dynamic>;
                  return data['name'].toString().toLowerCase().contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No products found"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.solar_power)),
                        title: Text("${data['name']} (${data['spec']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Price: Rs. ${data['price']} | Stock: ${data['units']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // 'mainAxisAlignment' ki jagah 'mainAxisSize' use karein
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _updatePrice(docs[index].id, (data['price'] as num).toDouble())
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _firestore.collection('products').doc(docs[index].id).delete()
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
