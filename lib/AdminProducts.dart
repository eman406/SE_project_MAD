import 'package:flutter/material.dart';
import 'Admin.dart';
class AdminProductManagement extends StatefulWidget {
  const AdminProductManagement({super.key});

  @override
  State<AdminProductManagement> createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  int _selectedIndex = 3; // ✅ Set to Products tab

  // Sample initial product data
  List<SolarProduct> myProducts = [
    SolarProduct(
      name: "MONOCRYSTALLINE",
      spec: "SOLAR PANEL 400W",
      price: 299.99,
      units: 89,
      status: "Active (Optimal)",
      icon: Icons.grid_view_rounded,
    ),
    SolarProduct(
      name: "SOLAR HYBRID",
      spec: "INVERTER 5KW",
      price: 849.00,
      units: 25,
      status: "Active",
      icon: Icons.power,
    ),
    SolarProduct(
      name: "DEEP CYCLE SOLAR",
      spec: "BATTERY (12V 200AH)",
      price: 419.00,
      units: 15,
      status: "Low Stock",
      icon: Icons.battery_charging_full,
    ),
    SolarProduct(
      name: "MPPT CHARGE",
      spec: "CONTROLLER (60A)",
      price: 179.99,
      units: 0,
      status: "Out of Stock",
      icon: Icons.settings_input_component,
    ),
  ];

  // ✅ Navigation Handler
  void _onItemTapped(int index) {
    if (index == 0) {
      // Go back to Dashboard
      Navigator.pop(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // Add navigation for other tabs if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      // --- A. The Common Header ---
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
          // --- B. Product Management Body (Search + List) ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Product Management Title and search/filter bar
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

                  // The dynamic list of products
                  Expanded(
                    child: ListView.builder(
                      itemCount: myProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductListItem(myProducts[index], index);
                      },
                    ),
                  ),

                  // --- C. Add Product Button ---
                  _buildAddProductButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- D. The Common Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // ✅ Added navigation handler
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

  // --- E. List Item Widget & Functionality ---

  // Build an individual product tile
  Widget _buildProductListItem(SolarProduct product, int index) {
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
          // 1. Icon (Placeholder for panel/battery/controller/inverter)
          _buildImageIconPlaceholder(product.icon),
          const SizedBox(width: 12),

          // 2. Product Details (Column 1)
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

          // 3. Product Status & Actions (Column 2)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status with icon/trend
                _buildStatusRow(product),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton("UPDATE PRICE", Colors.green, Colors.teal, () {
                      _showSnackBar("Update Price: Coming Soon");
                    }),
                    const SizedBox(width: 6),
                    _buildActionButton("DELETE", Colors.red, Colors.redAccent, () {
                      setState(() {
                        myProducts.removeAt(index);
                      });
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

  // --- H. Form & ADD Functionality ---

  // Shows a popup form to add a new product
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
                        setState(() {
                          myProducts.insert(
                              0,
                              SolarProduct(
                                name: pName.toUpperCase(),
                                spec: pSpec.toUpperCase(),
                                price: double.tryParse(pPrice) ?? 0.0,
                                units: int.tryParse(pUnits) ?? 0,
                                status: "Active (Optimal)",
                                icon: Icons.solar_power,
                              ));
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

  // Helper function to show a snackbar
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // --- I. Minor Helper UI Builders ---

  // Placeholder for product image icon
  Widget _buildImageIconPlaceholder(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, size: 30, color: Colors.blue),
    );
  }

  // Builds the complex status row
  Widget _buildStatusRow(SolarProduct product) {
    final statusMap = {
      'Active (Optimal)': {'icon': Icons.trending_up, 'color': Colors.green},
      'Active': {'icon': Icons.trending_flat, 'color': Colors.yellow[700]},
      'Low Stock': {'icon': Icons.info_outline, 'color': Colors.blue},
      'Out of Stock': {'icon': Icons.cancel, 'color': Colors.grey},
    };

    final sInfo = statusMap[product.status];
    final color = sInfo?['color'] as Color?;
    final iconData = sInfo?['icon'] as IconData?;

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

  // Builds an action button
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

  // Search input bar
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
          Text(
            "Search for solar products...",
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          )
        ],
      ),
    );
  }

  // Filter button
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

  // The large bottom 'ADD NEW PRODUCT' button
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
            Text(
              "ADD NEW PRODUCT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Product Data Model ---
class SolarProduct {
  final String name;
  final String spec;
  final double price;
  final int units;
  final String status;
  final IconData icon;

  SolarProduct({
    required this.name,
    required this.spec,
    required this.price,
    required this.units,
    required this.status,
    required this.icon,
  });
}