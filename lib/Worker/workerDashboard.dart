import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../login.dart';
import '../models/worker_model.dart';
import '../models/task_model.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F))),
      );
    }

    if (workerData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text("Profile not found or access denied.", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut().then((_) => 
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
                child: const Text("Logout", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    final List<Widget> pages = [
      HomeSection(worker: workerData!),
      TasksSection(workerId: currentUser!.uid),
      ProfileSection(worker: workerData!, onUpdate: _fetchWorkerData),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "SMART ENGINEERING" : _selectedIndex == 1 ? "Assigned Tasks" : "Account Settings"),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex == 0) _buildNotificationBadge(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks')
          .where('workerId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'Pending').snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            if (count > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              )
          ],
        );
      }
    );
  }
}

class HomeSection extends StatelessWidget {
  final WorkerModel worker;
  const HomeSection({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('workerId', isEqualTo: worker.id)
          .snapshots(),
      builder: (context, snapshot) {
        int assignedCount = 0;
        int completedCount = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            String status = doc['status'] ?? 'Pending';
            if (status == 'Completed') {
              completedCount++;
            } else if (status == 'Pending' || status == 'In Progress') {
              assignedCount++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              const Text("Job Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _statCard("Assigned", assignedCount.toString(), Colors.orange)),
                  const SizedBox(width: 15),
                  Expanded(child: _statCard("Completed", completedCount.toString(), Colors.green)),
                ],
              ),
              const SizedBox(height: 25),
              const Text("Quick Links", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
              const SizedBox(height: 15),
              _buildActionCard(context, "Check Safety Protocols", Icons.security, Colors.blue),
              _buildActionCard(context, "Service Guidelines", Icons.list_alt, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2D5A8E)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            backgroundImage: worker.profilePic.isNotEmpty ? NetworkImage(worker.profilePic) : null,
            child: worker.profilePic.isEmpty ? const Icon(Icons.person, size: 45, color: Colors.white) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, ${worker.name}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(worker.skill, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: Text(worker.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: color.withOpacity(0.2), width: 2)
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

class TasksSection extends StatelessWidget {
  final String workerId;
  const TasksSection({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').where('workerId', isEqualTo: workerId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F)));
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text("No tasks assigned yet.", style: TextStyle(color: Colors.grey, fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final task = TaskModel.fromFirestore(docs[index]);
            return _buildTaskCard(context, task);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    Color statusColor = Colors.orange;
    if (task.status == 'Completed') statusColor = Colors.green;
    if (task.status == 'Rejected') statusColor = Colors.red;
    if (task.status == 'In Progress') statusColor = Colors.blue;

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
                Expanded(child: Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                _statusChip(task.status, statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(color: Colors.black87, fontSize: 14)),
            const Divider(height: 32),
            _infoRow(Icons.location_on_outlined, task.location),
            _infoRow(Icons.access_time, DateFormat('dd MMM yyyy, hh:mm a').format(task.dateTime)),
            _infoRow(Icons.priority_high, "Priority: ${task.priority}"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, task, 'Rejected'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusPicker(context, task),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), foregroundColor: Colors.white),
                    child: const Text("Update Status"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, TaskModel task, String newStatus) async {
    try {
      // 1. Update Task Status
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({'status': newStatus});

      // 2. If it's linked to an installation, update the installation status too
      if (task.installationId != null) {
        String instStatus = 'Worker Assigned';
        if (newStatus == 'Completed') {
          instStatus = 'Installation Completed';
          await FirebaseFirestore.instance.collection('installations').doc(task.installationId).update({
            'status': instStatus,
            'completionDate': FieldValue.serverTimestamp(),
          });
        } else if (newStatus == 'In Progress') {
          instStatus = 'Installation In Progress';
          await FirebaseFirestore.instance.collection('installations').doc(task.installationId).update({
            'status': instStatus,
          });
        }
      }

      // 3. If it's linked to an order, update the order status
      if (task.orderId != null) {
        String orderStatus = 'Assigned';
        if (newStatus == 'Completed') {
          orderStatus = 'Delivered';
        } else if (newStatus == 'In Progress') {
          orderStatus = 'Processing';
        }
        await FirebaseFirestore.instance.collection('orders').doc(task.orderId).update({
          'status': orderStatus,
        });
      }

      // 4. If it's linked to a quotation
      if (task.quotationId != null) {
        String quotStatus = 'Worker Assigned';
        if (newStatus == 'Completed') quotStatus = 'Installation Completed';
        await FirebaseFirestore.instance.collection('quotations').doc(task.quotationId).update({
          'status': quotStatus,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status updated to $newStatus"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  void _showStatusPicker(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Update Task Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(leading: const Icon(Icons.pending_actions, color: Colors.orange), title: const Text("Pending"), onTap: () { _updateStatus(context, task, 'Pending'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.play_circle_outline, color: Colors.blue), title: const Text("In Progress"), onTap: () { _updateStatus(context, task, 'In Progress'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.check_circle_outline, color: Colors.green), title: const Text("Completed"), onTap: () { _updateStatus(context, task, 'Completed'); Navigator.pop(context); }),
            ],
          ),
        );
      }
    );
  }
}

class ProfileSection extends StatefulWidget {
  final WorkerModel worker;
  final VoidCallback onUpdate;
  const ProfileSection({super.key, required this.worker, required this.onUpdate});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool isEditing = false;
  late TextEditingController nameCtrl, phoneCtrl, addrCtrl, skillCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worker.name);
    phoneCtrl = TextEditingController(text: widget.worker.phone);
    addrCtrl = TextEditingController(text: widget.worker.address);
    skillCtrl = TextEditingController(text: widget.worker.skill);
  }

  Future<void> _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('approved_workers').doc(widget.worker.id).update({
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
        'address': addrCtrl.text,
        'skill': skillCtrl.text,
      });
      if (mounted) {
        setState(() => isEditing = false);
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          _buildProfilePic(),
          const SizedBox(height: 15),
          Text(widget.worker.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(widget.worker.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 30),
          _buildTextField("Full Name", nameCtrl, Icons.person, isEditing),
          _buildTextField("Phone Number", phoneCtrl, Icons.phone, isEditing),
          _buildTextField("Address", addrCtrl, Icons.location_on, isEditing),
          _buildTextField("Skill/Profession", skillCtrl, Icons.work, isEditing),
          _buildReadOnlyField("CNIC/ID", widget.worker.cnic.isEmpty ? "N/A" : widget.worker.cnic, Icons.badge),
          _buildReadOnlyField("Account Status", widget.worker.status.toUpperCase(), Icons.info_outline),
          const SizedBox(height: 25),
          isEditing 
            ? ElevatedButton(
                onPressed: _updateProfile, 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
            : OutlinedButton(
                onPressed: () => setState(() => isEditing = true),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("Edit Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildProfilePic() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: const Color(0xFF1E3A5F),
      backgroundImage: widget.worker.profilePic.isNotEmpty ? NetworkImage(widget.worker.profilePic) : null,
      child: widget.worker.profilePic.isEmpty ? const Icon(Icons.person, size: 70, color: Colors.white) : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
