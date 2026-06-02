import 'package:cloud_firestore/cloud_firestore.dart';

class QuotationModel {
  final String id;
  final int kw;
  final double price;
  final String panels;
  final String inverter;
  final String battery;
  final String details;
  final DateTime? updatedAt;

  QuotationModel({
    required this.id,
    required this.kw,
    required this.price,
    required this.panels,
    required this.inverter,
    required this.battery,
    required this.details,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'kw': kw,
      'price': price,
      'panels': panels,
      'inverter': inverter,
      'battery': battery,
      'details': details,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory QuotationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuotationModel(
      id: doc.id,
      kw: data['kw'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      panels: data['panels'] ?? '',
      inverter: data['inverter'] ?? '',
      battery: data['battery'] ?? '',
      details: data['details'] ?? '',
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
}
