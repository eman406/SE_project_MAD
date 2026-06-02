import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/installation_model.dart';
import '../models/worker_model.dart';
import 'package:intl/intl.dart';

class AdminInstallationScreen extends StatefulWidget {
  const AdminInstallationScreen({super.key});

  @override
  State<AdminInstallationScreen> createState() => _AdminInstallationScreenState();
}

class _AdminInstallationScreenState extends State<AdminInstallationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAssignWorkerDialog(InstallationModel installation) {
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
                  const Text("Assign Worker", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(workers[index].name),
                          subtitle: Text(workers[index].skill),
                          onTap: () => _assignWorker(installation, workers[index]),
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

  void _assignWorker(InstallationModel installation, WorkerModel worker) async {
    try {
      // 1. Update Installation document
      await _firestore.collection('installations').doc(installation.id).update({
        'workerId': worker.id,
        'workerName': worker.name,
        'status': 'Worker Assigned',
        'assignmentDate': FieldValue.serverTimestamp(),
      });

      // 2. Create a task in 'tasks' collection so it shows up for the worker
      await _firestore.collection('tasks').add({
        'title': 'Installation: ${installation.userName}',
        'description': 'System Size: ${installation.systemSize}. Contact: ${installation.userPhone}',
        'location': 'Client Location', // Replace with installation address if available in model
        'dateTime': Timestamp.now(),
        'priority': 'High',
        'assignedBy': 'Admin',
        'status': 'Pending',
        'workerId': worker.id,
        'installationId': installation.id,
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
        title: const Text("Installation Requests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('installations').orderBy('requestDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No installation requests found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final item = InstallationModel.fromFirestore(snapshot.data!.docs[index]);
              return _buildRequestCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(InstallationModel item) {
    bool canAssign = item.status == 'Pending Assignment';
    
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
                Text(item.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.bolt, "System Size", item.systemSize),
            _infoRow(Icons.payments_outlined, "Amount", "Rs. ${item.amount.toStringAsFixed(0)}"),
            _infoRow(Icons.phone, "User Phone", item.userPhone),
            _infoRow(Icons.calendar_today, "Request Date", DateFormat('dd MMM yyyy').format(item.requestDate)),
            
            if (item.workerName != null) ...[
              const Divider(height: 24),
              _infoRow(Icons.engineering, "Assigned Worker", item.workerName!, color: Colors.blue),
            ],
            
            if (canAssign) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignWorkerDialog(item),
                  icon: const Icon(Icons.person_add),
                  label: const Text("ASSIGN WORKER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blueGrey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Installation Completed') color = Colors.green;
    if (status == 'Worker Assigned') color = Colors.blue;
    if (status == 'Rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
