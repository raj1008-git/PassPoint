import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'receptionist' | 'staff'
  final String? departmentId;
  final String? departmentName;
  final String status; // 'pending' | 'active'
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.departmentId,
    this.departmentName,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isReceptionist => role == 'receptionist';
  bool get isStaff => role == 'staff';

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'status': status,
    'createdAt': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'staff',
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? departmentId,
    String? departmentName,
    String? status,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
