import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminQuotationScreen extends StatefulWidget {
  const AdminQuotationScreen({super.key});

  @override
  State<AdminQuotationScreen> createState() => _AdminQuotationScreenState();
}

class _AdminQuotationScreenState extends State<AdminQuotationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kwController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _panelsController = TextEditingController();
  final TextEditingController _inverterController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  bool _isLoading = false;

  // LOGIC: Save or Update Quotation (Standardized by KW size)
  Future<void> _saveQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      int kw = int.parse(_kwController.text.trim());
      String docId = "${kw}KW"; // document ID like 1KW, 5KW, etc.

      await _firestore.collection('quotations').doc(docId).set({
        'kw': kw,
        'price': double.parse(_priceController.text.trim()),
        'panels': _panelsController.text.trim(),
        'inverter': _inverterController.text.trim(),
        'battery': _batteryController.text.trim(),
        'details': _detailsController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$kw KW Quotation Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _kwController.clear();
    _priceController.clear();
    _panelsController.clear();
    _inverterController.clear();
    _batteryController.clear();
    _detailsController.clear();
  }

  void _editQuotation(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    _kwController.text = data['kw'].toString();
    _priceController.text = data['price'].toString();
    _panelsController.text = data['panels'] ?? '';
    _inverterController.text = data['inverter'] ?? '';
    _batteryController.text = data['battery'] ?? '';
    _detailsController.text = data['details'] ?? '';
  }

  Future<void> _deleteQuotation(String docId) async {
    try {
      await _firestore.collection('quotations').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quotation Deleted")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Manage System Prices", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Input Form ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text("Add / Update Standard Quotation", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _kwController,
                              decoration: const InputDecoration(labelText: "System Size (KW)", hintText: "e.g., 1, 5, 10"),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(labelText: "Official Price (Rs)"),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _panelsController,
                              decoration: const InputDecoration(labelText: "Solar Panels Detail", hintText: "e.g., 10 x 540W Mono"),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _inverterController,
                              decoration: const InputDecoration(labelText: "Inverter Detail"),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _batteryController,
                              decoration: const InputDecoration(labelText: "Battery Detail (Optional)"),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _detailsController,
                              decoration: const InputDecoration(labelText: "Installation & Service Details"),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),
                            _isLoading 
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : ElevatedButton(
                                  onPressed: _saveQuotation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("SAVE TO DATABASE", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Active Quotations in System", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
            ),

            // --- List of Quotations ---
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('quotations').orderBy('kw').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("No quotations added yet.")),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text("${data['kw']}K", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                        ),
                        title: Text("Rs. ${data['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        subtitle: Text("${data['panels']}\n${data['inverter']}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editQuotation(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuotation(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
