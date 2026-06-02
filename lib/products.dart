import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'User/categories.dart';
import 'User/cart_page.dart';

const Color primaryBlue = Color(0xFF0F4C81);
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
  String search = "";
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addToCart(Map<String, dynamic> product, String productId) async {
    if (user == null) return;
    
    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('items')
        .doc(productId);

    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'productId': productId,
        'productName': product['name'],
        'price': product['price'],
        'quantity': 1,
        'productImage': product['image'] ?? _img(product['name']),
      });
    }

    if (mounted) {
      // Clear existing snackbars to avoid buildup
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product['name']} added to cart"),
          backgroundColor: primaryBlue,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: yellow,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("SOLAR SHOP", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        actions: [
          _buildCartBadge(),
        ],
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No products found."));

                final docs = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? "").toString().toLowerCase();
                  return name.contains(search.toLowerCase());
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _productCard(data, docs[i].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildUserBottomNav(context, 1),
    );
  }

  Widget _buildCartBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cart').doc(user?.uid).collection('items').snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
          ],
        );
      },
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> data, String id) {
    final name = data['name'] ?? "Product";
    final price = (data['price'] ?? 0).toDouble();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                _img(name),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("Rs. ${price.toStringAsFixed(0)}", style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(data, id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text("ADD TO CART", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _img(String name) {
    if (name.toLowerCase().contains("panel")) return "https://images.unsplash.com/photo-1509391366360-2e959784a276";
    if (name.toLowerCase().contains("inverter")) return "https://images.unsplash.com/photo-1592833159155-c62df1b35631";
    if (name.toLowerCase().contains("battery")) return "https://images.unsplash.com/photo-1620714223084-8fcacc6dfd8d";
    return "https://images.unsplash.com/photo-1581092160562-40aa08e78837";
  }
}
