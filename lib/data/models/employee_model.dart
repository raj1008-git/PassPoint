import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String rowId;
  final String fullName;
  final String branchCode;
  final String branchName;
  final String mobileNo;
  final String email;
  final String departmentName;
  final String provinceName;
  final bool isHQStaff;
  final String status;
  final Timestamp lastSyncedAt;

  const EmployeeModel({
    required this.rowId,
    required this.fullName,
    required this.branchCode,
    required this.branchName,
    required this.mobileNo,
    required this.email,
    required this.departmentName,
    required this.provinceName,
    required this.isHQStaff,
    required this.status,
    required this.lastSyncedAt,
});
  bool get isActive=> status =='active';
  String get branchLabel=> isHQStaff? '$branchName (HQ)': branchName;

  Map<String,dynamic> toMap()=> {
    'rowId': rowId,
    'fullName':fullName,
    'branchCode': branchCode,
    'branchName': branchName,
    'mobileNo': mobileNo,
    'email': email,
    'departmentName': departmentName,
    'provinceName': provinceName,
    'isHQStaff': isHQStaff,
    'status': status,
    'lastSyncedAt': lastSyncedAt
  };

  factory EmployeeModel.fromMap(Map<String,dynamic> map){
    return EmployeeModel(
      rowId: map['rowId'] as String,
      fullName: map['fullName'] as String,
      branchCode: map['branchCode'] as String,
      branchName: map['branchName'] as String,
      mobileNo: map['mobileNo'] as String,
      email: map['email'] as String,
      departmentName: map['departmentName'] as String,
      provinceName: map['provinceName'] as String,
      isHQStaff: map['isHQStaff'] as bool,
      status: map['status'] as String,
      lastSyncedAt: map['lastSyncedAt'] as Timestamp,

    );
  }

  factory EmployeeModel.fromSnapshot(DocumentSnapshot doc){
    final data=doc.data() as Map<String,dynamic>;
    return EmployeeModel.fromMap(data);
  }

  EmployeeModel copyWith({
    String? rowId,
    String? fullName,
    String? branchName,
    String? branchCode,
    String? mobileNo,
    String? email,
    String? departmentName,
    String? provinceName,
    bool? isHQStaff,
    String? status,
    Timestamp? lastSyncedAt,
}){
    return EmployeeModel(
      rowId: rowId ?? this.rowId,
      fullName: fullName ?? this.fullName,
      branchCode: branchCode ?? this.branchCode,
      branchName: branchName ?? this.branchName,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      departmentName: departmentName ?? this.departmentName,
      provinceName: provinceName ?? this.provinceName,
      isHQStaff: isHQStaff ?? this.isHQStaff,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt


    );
  @override
    String toString(){
    'EmployeeModel(rowId: $rowId, fullName: $fullName, branchName: $branchName)';
  }
  }
}