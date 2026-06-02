import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import 'categories.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  const CheckoutPage({super.key, required this.totalAmount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final notesController = TextEditingController();
  bool isLoading = false;

  final User? user = FirebaseAuth.instance.currentUser;
  final Color primaryBlue = const Color(0xFF0F4C81);

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any existing SnackBars
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => isLoading = true);

    try {
      final cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('items')
          .get();

      if (cartItemsSnapshot.docs.isEmpty) {
        throw "Your cart is empty";
      }

      List<OrderItem> orderItems = cartItemsSnapshot.docs.map((doc) {
        return OrderItem(
          productId: doc['productId'] ?? '',
          productName: doc['productName'] ?? 'Unknown',
          price: (doc['price'] as num?)?.toDouble() ?? 0.0,
          quantity: doc['quantity'] ?? 1,
        );
      }).toList();

      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      
      await orderRef.set({
        'userId': user!.uid,
        'fullName': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'city': cityController.text,
        'notes': notesController.text,
        'items': orderItems.map((i) => i.toMap()).toList(),
        'totalAmount': widget.totalAmount,
        'status': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      // Clear Cart
      var batch = FirebaseFirestore.instance.batch();
      for (var doc in cartItemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: const Text("Order Placed Successfully!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesDashboard()),
                    (route) => false,
                  );
                },
                child: const Text("GO TO HOME"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout Details"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Shipping Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),
              _buildField("Full Name", nameController, Icons.person),
              _buildField("Mobile Number", phoneController, Icons.phone, keyboard: TextInputType.phone),
              _buildField("Complete Address", addressController, Icons.home),
              _buildField("City", cityController, Icons.location_city),
              _buildField("Additional Notes (Optional)", notesController, Icons.note, maxLines: 3),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Amount to Pay:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Rs. ${widget.totalAmount.toStringAsFixed(0)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("PLACE ORDER NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty && label != "Additional Notes (Optional)" ? "Field required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
