import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String priority; // High, Medium, Low
  final String assignedBy;
  final String status; // Pending, In Progress, Completed, Rejected
  final String workerId;
  final String? installationId; 
  final String? orderId;
  final String? quotationId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.priority,
    required this.assignedBy,
    required this.status,
    required this.workerId,
    this.installationId,
    this.orderId,
    this.quotationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'priority': priority,
      'assignedBy': assignedBy,
      'status': status,
      'workerId': workerId,
      'installationId': installationId,
      'orderId': orderId,
      'quotationId': quotationId,
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? 'New Task',
      description: data['description'] ?? '',
      location: data['location'] ?? 'Not Specified',
      dateTime: data['dateTime'] != null 
          ? (data['dateTime'] as Timestamp).toDate() 
          : DateTime.now(),
      priority: data['priority'] ?? 'Medium',
      assignedBy: data['assignedBy'] ?? 'Admin',
      status: data['status'] ?? 'Pending',
      workerId: data['workerId'] ?? '',
      installationId: data['installationId'],
      orderId: data['orderId'],
      quotationId: data['quotationId'],
    );
  }
}
