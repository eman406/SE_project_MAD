import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/worker_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showStatusDialog(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        List<String> statuses = ['Pending', 'Processing', 'Assigned', 'Out For Delivery', 'Delivered', 'Cancelled'];
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Update Order Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...statuses.map((status) => ListTile(
                title: Text(status),
                onTap: () {
                  _firestore.collection('orders').doc(order.id).update({'status': status});
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showAssignWorkerDialog(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('approved_workers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No workers available."));
            
            var workers = snapshot.data!.docs.map((doc) => WorkerModel.fromFirestore(doc)).toList();

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Assign Worker to Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(workers[index].name),
                          subtitle: Text(workers[index].skill),
                          onTap: () => _assignWorker(order, workers[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _assignWorker(OrderModel order, WorkerModel worker) async {
    try {
      // 1. Update Order
      await _firestore.collection('orders').doc(order.id).update({
        'workerId': worker.id,
        'status': 'Assigned'
      });

      // 2. Create Task for Worker so it appears in Worker Panel
      await _firestore.collection('tasks').add({
        'title': 'Delivery: ${order.fullName}',
        'description': 'Customer: ${order.fullName}. Items: ${order.items.length}. Amount: Rs. ${order.totalAmount}',
        'location': '${order.address}, ${order.city}',
        'dateTime': Timestamp.now(),
        'priority': 'Medium',
        'assignedBy': 'Admin',
        'status': 'Pending',
        'workerId': worker.id,
        'orderId': order.id,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Assigned to ${worker.name}"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
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
        title: const Text("Manage Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No orders found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final order = OrderModel.fromFirestore(snapshot.data!.docs[index]);
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _statusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text("Phone: ${order.phone}", style: const TextStyle(color: Colors.grey)),
            Text("Address: ${order.address}, ${order.city}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            ...order.items.map((item) => Text("${item.productName} x${item.quantity}")),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: Rs. ${order.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      onPressed: () => _showStatusDialog(order),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.orange),
                      onPressed: () => _showAssignWorkerDialog(order),
                    ),
                  ],
                )
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
