import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String toMeet;
  final String purpose;
  final String photoUrl;
  final String? signatureUrl;
  final Timestamp checkInTime;
  final Timestamp? checkOutTime;
  final String status;
  final String? departmentId;
  final String? departmentName;

  // NEW FIELD
  final int numberOfVisitors;

  Visitor({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.toMeet,
    required this.purpose,
    required this.photoUrl,
    this.signatureUrl,
    required this.checkInTime,
    this.checkOutTime,
    this.status = 'pending',
    this.departmentId,
    this.departmentName,
    this.numberOfVisitors = 1, // Default to 1 visitor
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'toMeet': toMeet,
    'purpose': purpose,
    'photoUrl': photoUrl,
    'signatureUrl': signatureUrl,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'status': status,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'numberOfVisitors': numberOfVisitors, // NEW
  };

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      toMeet: map['toMeet'] as String,
      purpose: map['purpose'] as String,
      photoUrl: map['photoUrl'] as String,
      signatureUrl: map['signatureUrl'] as String?,
      checkInTime: map['checkInTime'] is Timestamp
          ? map['checkInTime'] as Timestamp
          : Timestamp.fromDate(DateTime.parse(map['checkInTime'] as String)),
      checkOutTime: map['checkOutTime'] != null
          ? map['checkOutTime'] as Timestamp?
          : null,
      status: map['status'] as String? ?? 'pending',
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      numberOfVisitors: map['numberOfVisitors'] as int? ?? 1, // NEW with fallback
    );
  }
}