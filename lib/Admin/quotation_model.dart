import 'package:cloud_firestore/cloud_firestore.dart';

class QuotationModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileSize;
  final DateTime uploadDate;
  final String uploadedBy;

  QuotationModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadDate,
    required this.uploadedBy,
  });

  factory QuotationModel.fromFirestore(
      DocumentSnapshot doc,
      ) {
    Map<String, dynamic> data =
    doc.data() as Map<String, dynamic>;

    return QuotationModel(
      id: doc.id,
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileSize: data['fileSize'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadDate:
      (data['uploadDate'] as Timestamp?)
          ?.toDate() ??
          DateTime.now(),
    );
  }
}