import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin.dart';

class AdminProductManagement extends StatefulWidget {
  const AdminProductManagement({super.key});

  @override
  State<AdminProductManagement> createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  int _selectedIndex = 3;
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.person, color: Colors.green),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ADMIN DASHBOARD",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Solar Energy Platform Overview",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle_outline)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Product Management",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Manage solar products, prices, and inventory",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildSearchBar()),
                          const SizedBox(width: 8),
                          _buildFilterButton(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Firestore StreamBuilder for real-time updates
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
                        if (docs.isEmpty) {
                          return const Center(child: Text("No products found. Add your first one!"));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final product = SolarProduct.fromMap(data, docs[index].id);
                            return _buildProductListItem(product, docs[index].id);
                          },
                        );
                      },
                    ),
                  ),

                  _buildAddProductButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), label: 'Workers'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.solar_power_outlined), label: 'Installations'),
        ],
      ),
    );
  }

  Widget _buildProductListItem(SolarProduct product, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageIconPlaceholder(product.getIconData()),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  product.spec,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${product.units} UNITS",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusRow(product),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton("UPDATE PRICE", Colors.green, Colors.teal, () {
                      _showUpdatePriceDialog(docId, product.price);
                    }),
                    const SizedBox(width: 6),
                    _buildActionButton("DELETE", Colors.red, Colors.redAccent, () {
                      productsRef.doc(docId).delete();
                      _showSnackBar("${product.spec} Removed");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceDialog(String docId, double currentPrice) {
    final TextEditingController controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Price"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Price"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              double? newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                productsRef.doc(docId).update({'price': newPrice});
                Navigator.pop(context);
                _showSnackBar("Price Updated");
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showAddProductForm() {
    String pName = '';
    String pSpec = '';
    String pPrice = '';
    String pUnits = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  decoration: const InputDecoration(labelText: 'Name (e.g., SOLAR PANEL)'),
                  onChanged: (v) => pName = v),
              TextField(
                  decoration: const InputDecoration(labelText: 'Spec (e.g., 400W)'),
                  onChanged: (v) => pSpec = v),
              TextField(
                  decoration: const InputDecoration(labelText: 'Price (\$)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => pPrice = v),
              TextField(
                  decoration: const InputDecoration(labelText: 'Units'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => pUnits = v),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        productsRef.add({
                          'name': pName.toUpperCase(),
                          'spec': pSpec.toUpperCase(),
                          'price': double.tryParse(pPrice) ?? 0.0,
                          'units': int.tryParse(pUnits) ?? 0,
                          'status': (int.tryParse(pUnits) ?? 0) > 0 ? "Active" : "Out of Stock",
                          'iconType': 'solar', // default icon type
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        _showSnackBar("New Product Added Successfully!");
                        Navigator.pop(context);
                      },
                      child: const Text("Create",
                          style: TextStyle(color: Colors.white))),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildImageIconPlaceholder(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, size: 30, color: Colors.blue),
    );
  }

  Widget _buildStatusRow(SolarProduct product) {
    final statusMap = {
      'Active (Optimal)': {'icon': Icons.trending_up, 'color': Colors.green},
      'Active': {'icon': Icons.trending_flat, 'color': Colors.yellow[700]},
      'Low Stock': {'icon': Icons.info_outline, 'color': Colors.blue},
      'Out of Stock': {'icon': Icons.cancel, 'color': Colors.grey},
    };

    final sInfo = statusMap[product.status] ?? statusMap['Active'];
    final color = sInfo!['color'] as Color?;
    final iconData = sInfo['icon'] as IconData?;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "STATUS:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              product.status,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Icon(iconData, color: color, size: 24),
      ],
    );
  }

  Widget _buildActionButton(String label, Color startColor, Color endColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(colors: [startColor, endColor]),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for solar products...",
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.grey[600], size: 16),
          const SizedBox(width: 4),
          Text(
            "FILTER",
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildAddProductButton() {
    return InkWell(
      onTap: _showAddProductForm,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [
            Color(0xFFFDD835),
            Colors.green,
          ]),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_to_photos_outlined, size: 20),
            SizedBox(width: 10),
            const Text(
              "ADD NEW PRODUCT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class SolarProduct {
  final String id;
  final String name;
  final String spec;
  final double price;
  final int units;
  final String status;
  final String iconType;

  SolarProduct({
    required this.id,
    required this.name,
    required this.spec,
    required this.price,
    required this.units,
    required this.status,
    required this.iconType,
  });

  factory SolarProduct.fromMap(Map<String, dynamic> data, String id) {
    return SolarProduct(
      id: id,
      name: data['name'] ?? '',
      spec: data['spec'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      units: data['units'] ?? 0,
      status: data['status'] ?? 'Active',
      iconType: data['iconType'] ?? 'solar',
    );
  }

  IconData getIconData() {
    switch (iconType) {
      case 'battery': return Icons.battery_charging_full;
      case 'power': return Icons.power;
      case 'settings': return Icons.settings_input_component;
      default: return Icons.solar_power;
    }
  }
}
