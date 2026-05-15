import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = "Not tested";
  bool _isLoading = false;

  Future<void> _testFirestore() async {
    setState(() {
      _isLoading = true;
      _status = "Connecting...";
    });

    try {
      // Attempt to add a document to a 'connection_test' collection
      final docRef = await FirebaseFirestore.instance.collection('connection_test').add({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connected successfully!',
        'platform': Theme.of(context).platform.toString(),
      });

      setState(() {
        _status = "Success! Document ID: ${docRef.id}";
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
      developer.log("Firebase Error", error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Connection Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                "Status: $_status",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _testFirestore,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text("Test Connection"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
