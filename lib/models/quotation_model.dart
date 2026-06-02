import 'package:cloud_firestore/cloud_firestore.dart';

class QuotationModel {
  final String id;
  final String fileName; // This will be the KW name (e.g., 10 KW)
  final String fileUrl;
  final DateTime uploadDate;
  final String fileSize;
  final String uploadedBy;

  QuotationModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploadDate,
    required this.fileSize,
    required this.uploadedBy,
  });

  factory QuotationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuotationModel(
      id: doc.id,
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
      fileSize: data['fileSize'] ?? '',
      uploadedBy: data['uploadedBy'] ?? 'Admin',
    );
  }
}
