import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

class AdminWorkerScreen extends StatefulWidget {
  const AdminWorkerScreen({super.key});

  @override
  State<AdminWorkerScreen> createState() => _AdminWorkerScreenState();
}

class _AdminWorkerScreenState extends State<AdminWorkerScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // LOGIC: Approve Worker (Move from pending_workers to approved_workers collection)
  void _approveWorker(WorkerModel worker) async {
    try {
      // 1. Move data to 'approved_workers' collection (Standardized Name)
      await _firestore.collection('approved_workers').doc(worker.id).set({
        'uid': worker.id,
        'name': worker.name,
        'email': worker.email,
        'phone': worker.phone,
        'skill': worker.skill,
        'address': worker.address,
        'experience': worker.experience,
        'status': 'approved',
        'role': 'Worker',
        'createdAt': worker.createdAt,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // 2. Delete from 'pending_workers'
      await _firestore.collection('pending_workers').doc(worker.id).delete();

      // 3. Cleanup: Ensure worker is not in the normal 'users' collection
      await _firestore.collection('users').doc(worker.id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Worker Approved Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      _showError("Approval failed: $e");
    }
  }

  void _rejectRequest(String id) async {
    await _firestore.collection('pending_workers').doc(id).delete();
    _showSnackBar("Registration Request Dismissed", Colors.red);
  }

  void _deleteWorker(String id) async {
    await _firestore.collection('approved_workers').doc(id).delete();
    _showSnackBar("Worker Profile Deleted", Colors.black);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _showError(String msg) {
    _showSnackBar(msg, Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin_dashboard'),
        ),
        title: const Text("WORKER HUB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E3A5F),
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: "Requests", icon: Icon(Icons.pending_actions)),
            Tab(text: "Management", icon: Icon(Icons.engineering)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(collection: 'pending_workers', isRequest: true),
                _buildList(collection: 'approved_workers', isRequest: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Search workers by name...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildList({required String collection, required bool isRequest}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        var docs = snapshot.data?.docs ?? [];
        var filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['name'] ?? '').toString().toLowerCase().contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(child: Text("No records found in '$collection'"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final worker = WorkerModel.fromFirestore(filteredDocs[index]);
            return _buildWorkerCard(worker, isRequest);
          },
        );
      },
    );
  }

  Widget _buildWorkerCard(WorkerModel worker, bool isRequest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isRequest ? Colors.orange[50] : Colors.blue[50],
          child: Icon(isRequest ? Icons.hourglass_top : Icons.verified, 
                     color: isRequest ? Colors.orange : Colors.blue),
        ),
        title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${worker.skill} • ${worker.email}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(Icons.phone, "Phone", worker.phone),
                _row(Icons.location_on, "Address", worker.address),
                _row(Icons.history, "Exp", "${worker.experience} Years"),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isRequest) ...[
                      TextButton(
                        onPressed: () => _rejectRequest(worker.id),
                        child: const Text("DISMISS", style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _approveWorker(worker),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("APPROVE", style: TextStyle(color: Colors.white)),
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: () => _deleteWorker(worker.id),
                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                        label: const Text("DELETE ACCOUNT", style: TextStyle(color: Colors.red)),
                      ),
                    ]
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}