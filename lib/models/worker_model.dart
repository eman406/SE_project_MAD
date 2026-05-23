import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String skill;
  final String address;
  final String experience;
  final String status;
  final String cnic;
  final String profilePic;
  final DateTime createdAt;

  WorkerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.skill,
    required this.address,
    required this.experience,
    required this.status,
    required this.cnic,
    required this.profilePic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'skill': skill,
      'address': address,
      'experience': experience,
      'status': status,
      'cnic': cnic,
      'profilePic': profilePic,
      'createdAt': createdAt,
    };
  }

  factory WorkerModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return WorkerModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      skill: data['skill'] ?? 'Not Specified',
      address: data['address'] ?? 'Not Specified',
      experience: data['experience'] ?? '0',
      status: data['status'] ?? 'pending',
      cnic: data['cnic'] ?? '',
      profilePic: data['profilePic'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}
