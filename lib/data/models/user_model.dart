import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String? email; // NOW OPTIONAL (for staff)
  final String phoneNumber; // NEW - MANDATORY for staff
  final String role; // 'receptionist' | 'staff'

  // Branch fields (NEW)
  final String? branchId;
  final String? branchName;

  // Department fields (only for HQ staff)
  final String? departmentId;
  final String? departmentName;

  final String status; // 'pending' | 'active'
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    required this.phoneNumber,
    required this.role,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    required this.status,
    required this.createdAt,
  });

  // Convenience getters
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isReceptionist => role == 'receptionist';
  bool get isStaff => role == 'staff';
  bool get isHQStaff => branchName == 'KAMALADI' || branchId == 'kamaladi';
  bool get isBranchStaff => isStaff && !isHQStaff;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': role,
    'branchId': branchId,
    'branchName': branchName,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'status': status,
    'createdAt': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String?, // Nullable
      phoneNumber:
          map['phoneNumber'] as String? ??
          map['phone'] as String? ??
          '', // Fallback to 'phone'
      role: map['role'] as String? ?? 'staff',
      branchId: map['branchId'] as String?,
      branchName: map['branchName'] as String?,
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
    String? phoneNumber,
    String? role,
    String? branchId,
    String? branchName,
    String? departmentId,
    String? departmentName,
    String? status,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
