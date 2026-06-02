import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../login.dart';
import '../models/worker_model.dart';
import '../models/task_model.dart';
import '../models/order_model.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  WorkerModel? workerData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
  }

  Future<void> _fetchWorkerData() async {
    if (currentUser == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('approved_workers')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        if (mounted) {
          setState(() {
            workerData = WorkerModel.fromFirestore(doc);
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching worker data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (workerData == null) return const Scaffold(body: Center(child: Text("Worker data not found.")));

    final List<Widget> pages = [
      AssignedWorkSection(workerId: currentUser!.uid),
      CompletedWorkSection(workerId: currentUser!.uid),
      WorkerProfileSection(worker: workerData!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Assigned Work" : _selectedIndex == 1 ? "Completed Work" : "My Profile"),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF1E3A5F),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Assigned"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Completed"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class AssignedWorkSection extends StatelessWidget {
  final String workerId;
  const AssignedWorkSection({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('workerId', isEqualTo: workerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var orders = snapshot.data!.docs.where((doc) => doc['status'] != 'Delivered' && doc['status'] != 'Cancelled').toList();
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = OrderModel.fromFirestore(orders[index]);
            return _workCard(context, order);
          },
        );
      },
    );
  }

  Widget _workCard(BuildContext context, OrderModel order) {
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
                Text(order.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _statusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text("Address: ${order.address}, ${order.city}"),
            Text("Phone: ${order.phone}"),
            const Divider(),
            ...order.items.map((item) => Text("${item.productName} x${item.quantity}")),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(order.id, 'Processing'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("In Progress"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(order.id, 'Delivered'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("Completed"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _updateStatus(String orderId, String status) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': status});
  }
}

class CompletedWorkSection extends StatelessWidget {
  final String workerId;
  const CompletedWorkSection({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'Delivered')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var orders = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = OrderModel.fromFirestore(orders[index]);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(order.fullName),
                subtitle: Text("Completed on: ${DateFormat('dd MMM yyyy').format(order.orderDate)}"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}

class WorkerProfileSection extends StatelessWidget {
  final WorkerModel worker;
  const WorkerProfileSection({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.engineering, size: 50)),
          const SizedBox(height: 20),
          Text(worker.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(worker.email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text("Skill: ${worker.skill}"),
          Text("Phone: ${worker.phone}"),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
