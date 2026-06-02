import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'categories.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryBlue = Color(0xFF0F4C81);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: user == null 
        ? const Center(child: Text("Please login to see your orders"))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text("No orders placed yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              // Create a modifiable list from the snapshot and sort manually
              // This bypasses the need for a manual composite index in Firestore
              List<QueryDocumentSnapshot> docs = List.from(snapshot.data!.docs);
              docs.sort((a, b) {
                var aData = a.data() as Map<String, dynamic>;
                var bData = b.data() as Map<String, dynamic>;
                Timestamp? aTime = aData['orderDate'] as Timestamp?;
                Timestamp? bTime = bData['orderDate'] as Timestamp?;
                if (aTime == null) return -1;
                if (bTime == null) return 1;
                return bTime.compareTo(aTime); // Latest first
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  try {
                    final order = OrderModel.fromFirestore(docs[index]);
                    return _orderCard(order);
                  } catch (e) {
                    return Card(
                      child: ListTile(
                        title: const Text("Error loading order details"),
                        subtitle: Text(e.toString()),
                      ),
                    );
                  }
                },
              );
            },
          ),
      bottomNavigationBar: buildUserBottomNav(context, 3),
    );
  }

  Widget _orderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order ID: ${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                _statusBadge(order.status),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("${item.productName} x${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text("Rs. ${(item.price * item.quantity).toStringAsFixed(0)}"),
                ],
              ),
            )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Total: Rs. ${order.totalAmount.toStringAsFixed(0)}", 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F4C81))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Delivered') color = Colors.green;
    if (status == 'Processing') color = Colors.blue;
    if (status == 'Cancelled') color = Colors.red;
    if (status == 'Out For Delivery') color = Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
