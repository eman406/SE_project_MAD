import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});

  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final skillsController = TextEditingController();
  final expController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;

  void submitRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        // Use user.uid as Document ID to maintain consistency
        await FirebaseFirestore.instance.collection('pending_workers').doc(user.uid).set({
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'skill': skillsController.text.trim(),
          'experience': expController.text.trim(),
          'address': addressController.text.trim(),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Request Submitted"),
            content: const Text("Your registration request has been submitted. Admin will review your profile shortly."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register as Worker"),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.engineering_outlined, size: 80, color: Color(0xFF1E3A5F)),
                const SizedBox(height: 10),
                const Text("Worker Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("Submit your details for admin approval"),
                const SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: skillsController,
                  decoration: const InputDecoration(labelText: "Skills (e.g. Electrician, Solar Expert)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.build)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: expController,
                  decoration: const InputDecoration(labelText: "Experience (Years)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.history)),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Complete Address", border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 30),
                isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Submit Registration", style: TextStyle(fontSize: 18)),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
