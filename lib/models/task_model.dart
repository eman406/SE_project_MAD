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
  final String? installationId; // Link to installation request

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
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      dateTime: data['dateTime'] != null ? (data['dateTime'] as Timestamp).toDate() : DateTime.now(),
      priority: data['priority'] ?? 'Medium',
      assignedBy: data['assignedBy'] ?? 'Admin',
      status: data['status'] ?? 'Pending',
      workerId: data['workerId'] ?? '',
      installationId: data['installationId'],
    );
  }
}
