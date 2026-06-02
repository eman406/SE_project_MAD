import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? notes;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // Pending, Processing, Assigned, Out For Delivery, Delivered, Cancelled
  final DateTime orderDate;
  final String? workerId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.notes,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.workerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'notes': notes,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate,
      'workerId': workerId,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      notes: data['notes'],
      items: (data['items'] as List?)?.map((i) => OrderItem.fromMap(i)).toList() ?? [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      orderDate: data['orderDate'] != null 
          ? (data['orderDate'] as Timestamp).toDate() 
          : DateTime.now(),
      workerId: data['workerId'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
    );
  }
}
