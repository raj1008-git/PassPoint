import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;

  // Registration Details
  final String registrationNumber; // Darta Number (e.g., HQ-1, BR-500)
  final Timestamp registrationDate; // Darta Date
  final String receivedLetterNumber; // Prapta Bhayeko Patra Sankhya
  final Timestamp receivedLetterDate; // Prapta Bhayeko Patra Ko Miti
  final String senderOfficeName; // Pathaune Office Ko Naam
  final String subject; // Bishaya / Description

  // NEW: Source Information (for staff check-in)
  final String sourceType; // "public" | "staff"
  final String? sourceBranch; // "KAMALADI" | "POKHARA" etc.
  final String? sourceDepartment; // "IT" (only if HQ staff)
  final String? createdByStaffId; // Staff UID who created it
  final bool skipReceptionist; // true for HQ→Branch, false for Branch→HQ

  // Routing Information
  final String targetDepartmentId;
  final String targetDepartmentName;
  final String targetPersonName;
  final String? targetBranch; // NEW: For HQ→Branch direct delivery

  // Optional Delivery Info (only for public check-in)
  final String? productPhotoUrl;
  final String? deliveryPersonName;
  final String? deliveryPersonContact;

  // Status Tracking
  final String
  currentStatus; // submitted, received_by_reception, forwarded, completed
  final Timestamp createdAt;
  final Timestamp? completedAt;

  // Current Location
  final String? currentDepartmentId;
  final String? currentDepartmentName;
  final String? currentPersonName;

  // Status History (stored as list of maps)
  final List<Map<String, dynamic>> statusHistory;

  // NEW: Badge Notifications (for Phase 3)
  final List<String> unreadByStaff; // Array of staff UIDs who haven't viewed

  ProductModel({
    required this.id,
    required this.registrationNumber,
    required this.registrationDate,
    required this.receivedLetterNumber,
    required this.receivedLetterDate,
    required this.senderOfficeName,
    required this.subject,
    this.sourceType = 'public', // Default to public
    this.sourceBranch,
    this.sourceDepartment,
    this.createdByStaffId,
    this.skipReceptionist = false,
    required this.targetDepartmentId,
    required this.targetDepartmentName,
    required this.targetPersonName,
    this.targetBranch,
    this.productPhotoUrl,
    this.deliveryPersonName,
    this.deliveryPersonContact,
    required this.currentStatus,
    required this.createdAt,
    this.completedAt,
    this.currentDepartmentId,
    this.currentDepartmentName,
    this.currentPersonName,
    required this.statusHistory,
    this.unreadByStaff = const [],
  });

  // Convenience getters
  bool get isStaffProduct => sourceType == 'staff';
  bool get isPublicProduct => sourceType == 'public';
  bool get isHQtoBranch => skipReceptionist == true;
  bool get isBranchToHQ =>
      skipReceptionist == false && sourceBranch != 'KAMALADI';

  Map<String, dynamic> toMap() => {
    'id': id,
    'registrationNumber': registrationNumber,
    'registrationDate': registrationDate,
    'receivedLetterNumber': receivedLetterNumber,
    'receivedLetterDate': receivedLetterDate,
    'senderOfficeName': senderOfficeName,
    'subject': subject,
    'sourceType': sourceType,
    'sourceBranch': sourceBranch,
    'sourceDepartment': sourceDepartment,
    'createdByStaffId': createdByStaffId,
    'skipReceptionist': skipReceptionist,
    'targetDepartmentId': targetDepartmentId,
    'targetDepartmentName': targetDepartmentName,
    'targetPersonName': targetPersonName,
    'targetBranch': targetBranch,
    'productPhotoUrl': productPhotoUrl,
    'deliveryPersonName': deliveryPersonName,
    'deliveryPersonContact': deliveryPersonContact,
    'currentStatus': currentStatus,
    'createdAt': createdAt,
    'completedAt': completedAt,
    'currentDepartmentId': currentDepartmentId,
    'currentDepartmentName': currentDepartmentName,
    'currentPersonName': currentPersonName,
    'statusHistory': statusHistory,
    'unreadByStaff': unreadByStaff,
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      registrationNumber: map['registrationNumber'] as String,
      registrationDate: map['registrationDate'] as Timestamp,
      receivedLetterNumber: map['receivedLetterNumber'] as String,
      receivedLetterDate: map['receivedLetterDate'] as Timestamp,
      senderOfficeName: map['senderOfficeName'] as String,
      subject: map['subject'] as String,
      sourceType: map['sourceType'] as String? ?? 'public',
      sourceBranch: map['sourceBranch'] as String?,
      sourceDepartment: map['sourceDepartment'] as String?,
      createdByStaffId: map['createdByStaffId'] as String?,
      skipReceptionist: map['skipReceptionist'] as bool? ?? false,
      targetDepartmentId: map['targetDepartmentId'] as String,
      targetDepartmentName: map['targetDepartmentName'] as String,
      targetPersonName: map['targetPersonName'] as String,
      targetBranch: map['targetBranch'] as String?,
      productPhotoUrl: map['productPhotoUrl'] as String?,
      deliveryPersonName: map['deliveryPersonName'] as String?,
      deliveryPersonContact: map['deliveryPersonContact'] as String?,
      currentStatus: map['currentStatus'] as String,
      createdAt: map['createdAt'] as Timestamp,
      completedAt: map['completedAt'] as Timestamp?,
      currentDepartmentId: map['currentDepartmentId'] as String?,
      currentDepartmentName: map['currentDepartmentName'] as String?,
      currentPersonName: map['currentPersonName'] as String?,
      statusHistory: List<Map<String, dynamic>>.from(
        map['statusHistory'] as List? ?? [],
      ),
      unreadByStaff: List<String>.from(map['unreadByStaff'] as List? ?? []),
    );
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data);
  }

  ProductModel copyWith({
    String? id,
    String? registrationNumber,
    Timestamp? registrationDate,
    String? receivedLetterNumber,
    Timestamp? receivedLetterDate,
    String? senderOfficeName,
    String? subject,
    String? sourceType,
    String? sourceBranch,
    String? sourceDepartment,
    String? createdByStaffId,
    bool? skipReceptionist,
    String? targetDepartmentId,
    String? targetDepartmentName,
    String? targetPersonName,
    String? targetBranch,
    String? productPhotoUrl,
    String? deliveryPersonName,
    String? deliveryPersonContact,
    String? currentStatus,
    Timestamp? createdAt,
    Timestamp? completedAt,
    String? currentDepartmentId,
    String? currentDepartmentName,
    String? currentPersonName,
    List<Map<String, dynamic>>? statusHistory,
    List<String>? unreadByStaff,
  }) {
    return ProductModel(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      receivedLetterNumber: receivedLetterNumber ?? this.receivedLetterNumber,
      receivedLetterDate: receivedLetterDate ?? this.receivedLetterDate,
      senderOfficeName: senderOfficeName ?? this.senderOfficeName,
      subject: subject ?? this.subject,
      sourceType: sourceType ?? this.sourceType,
      sourceBranch: sourceBranch ?? this.sourceBranch,
      sourceDepartment: sourceDepartment ?? this.sourceDepartment,
      createdByStaffId: createdByStaffId ?? this.createdByStaffId,
      skipReceptionist: skipReceptionist ?? this.skipReceptionist,
      targetDepartmentId: targetDepartmentId ?? this.targetDepartmentId,
      targetDepartmentName: targetDepartmentName ?? this.targetDepartmentName,
      targetPersonName: targetPersonName ?? this.targetPersonName,
      targetBranch: targetBranch ?? this.targetBranch,
      productPhotoUrl: productPhotoUrl ?? this.productPhotoUrl,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryPersonContact:
          deliveryPersonContact ?? this.deliveryPersonContact,
      currentStatus: currentStatus ?? this.currentStatus,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      currentDepartmentId: currentDepartmentId ?? this.currentDepartmentId,
      currentDepartmentName:
          currentDepartmentName ?? this.currentDepartmentName,
      currentPersonName: currentPersonName ?? this.currentPersonName,
      statusHistory: statusHistory ?? this.statusHistory,
      unreadByStaff: unreadByStaff ?? this.unreadByStaff,
    );
  }
}
