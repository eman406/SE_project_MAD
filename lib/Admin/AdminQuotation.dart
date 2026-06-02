import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

class AdminQuotationScreen extends StatefulWidget {
  const AdminQuotationScreen({super.key});

  @override
  State<AdminQuotationScreen> createState() => _AdminQuotationScreenState();
}

class _AdminQuotationScreenState extends State<AdminQuotationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _updateStatus(String id, String status) async {
    await _firestore.collection('quotations').doc(id).update({'status': status});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Quotation $status"), backgroundColor: status == 'Approved' ? Colors.green : Colors.red));
    }
  }

  void _showAssignWorkerDialog(DocumentSnapshot quotation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('approved_workers').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            var workers = snapshot.data!.docs.map((doc) => WorkerModel.fromFirestore(doc)).toList();

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Assign Worker to Quotation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(workers[index].name),
                          subtitle: Text(workers[index].skill),
                          onTap: () => _assignWorker(quotation, workers[index]),
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

  void _assignWorker(DocumentSnapshot quotation, WorkerModel worker) async {
    try {
      // 1. Update Quotation
      await _firestore.collection('quotations').doc(quotation.id).update({
        'workerId': worker.id,
        'status': 'Worker Assigned'
      });

      // 2. Create Task for Worker
      await _firestore.collection('tasks').add({
        'title': 'Quotation/Installation: ${quotation['userName']}',
        'description': 'System: ${quotation['systemSize']}. Contact: ${quotation['userPhone']}',
        'location': 'Customer Location',
        'dateTime': Timestamp.now(),
        'priority': 'High',
        'assignedBy': 'Admin',
        'status': 'Pending',
        'workerId': worker.id,
        'quotationId': quotation.id,
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
        title: const Text("Manage Quotations", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quotations').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return _buildQuotationCard(docs[index], data);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuotationCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    String status = data['status'] ?? 'Pending';
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
                Text(data['userName'] ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 10),
            Text("System: ${data['systemSize']}", style: const TextStyle(color: Colors.grey)),
            Text("Phone: ${data['userPhone']}", style: const TextStyle(color: Colors.grey)),
            const Divider(),
            if (status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => _updateStatus(doc.id, 'Rejected'), child: const Text("Reject", style: TextStyle(color: Colors.red))),
                  ElevatedButton(onPressed: () => _updateStatus(doc.id, 'Approved'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("Approve")),
                ],
              )
            else if (status == 'Approved')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => _showAssignWorkerDialog(doc), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("Assign Worker")),
              )
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Approved' || status == 'Worker Assigned') color = Colors.green;
    if (status == 'Rejected') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
