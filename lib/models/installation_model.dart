import 'package:cloud_firestore/cloud_firestore.dart';

class InstallationModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String systemSize;
  final double amount;
  final String status; // Pending Assignment, Worker Assigned, Installation Completed, Rejected
  final DateTime requestDate;
  final String? workerId;
  final String? workerName;
  final DateTime? assignmentDate;
  final DateTime? completionDate;

  InstallationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.systemSize,
    required this.amount,
    required this.status,
    required this.requestDate,
    this.workerId,
    this.workerName,
    this.assignmentDate,
    this.completionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'systemSize': systemSize,
      'amount': amount,
      'status': status,
      'requestDate': requestDate,
      'workerId': workerId,
      'workerName': workerName,
      'assignmentDate': assignmentDate,
      'completionDate': completionDate,
    };
  }

  factory InstallationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InstallationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      systemSize: data['systemSize'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending Assignment',
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      workerId: data['workerId'],
      workerName: data['workerName'],
      assignmentDate: (data['assignmentDate'] as Timestamp?)?.toDate(),
      completionDate: (data['completionDate'] as Timestamp?)?.toDate(),
    );
  }
}
