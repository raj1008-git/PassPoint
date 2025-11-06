import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String toMeet;
  final String purpose;
  final String photoUrl;
  final Timestamp checkInTime;
  final Timestamp? checkOutTime;
  final String status;
  Visitor({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.toMeet,
    required this.purpose,
    required this.photoUrl,
    required this.checkInTime,
    this.checkOutTime,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'toMeet': toMeet,
    'purpose': purpose,
    'photoUrl': photoUrl,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'status': status,
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
      checkInTime: map['checkInTime'] is Timestamp
          ? map['checkInTime'] as Timestamp
          : Timestamp.fromDate(DateTime.parse(map['checkInTime'] as String)),
      checkOutTime: map['checkOutTime'] != null
          ? map['checkOutTime'] as Timestamp?
          : null,
      status: map['status'] as String? ?? 'pending',
    );
  }
}
