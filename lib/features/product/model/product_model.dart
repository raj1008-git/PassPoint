import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;

  // Registration Details
  final String registrationNumber; // Darta Number
  final Timestamp registrationDate; // Darta Date
  final String receivedLetterNumber; // Prapta Bhayeko Patra Sankhya
  final Timestamp receivedLetterDate; // Prapta Bhayeko Patra Ko Miti
  final String senderOfficeName; // Pathaune Office Ko Naam
  final String subject; // Bishaya / Description

  // Routing Information
  final String targetDepartmentId;
  final String targetDepartmentName;
  final String targetPersonName;

  // Optional Delivery Info
  final String? productPhotoUrl;
  final String? deliveryPersonName;
  final String? deliveryPersonContact;

  // Status Tracking
  final String currentStatus; // submitted, received_by_reception, forwarded, completed
  final Timestamp createdAt;
  final Timestamp? completedAt;

  // Current Location
  final String? currentDepartmentId;
  final String? currentDepartmentName;
  final String? currentPersonName;

  // Status History (stored as list of maps)
  final List<Map<String, dynamic>> statusHistory;

  ProductModel({
    required this.id,
    required this.registrationNumber,
    required this.registrationDate,
    required this.receivedLetterNumber,
    required this.receivedLetterDate,
    required this.senderOfficeName,
    required this.subject,
    required this.targetDepartmentId,
    required this.targetDepartmentName,
    required this.targetPersonName,
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
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'registrationNumber': registrationNumber,
    'registrationDate': registrationDate,
    'receivedLetterNumber': receivedLetterNumber,
    'receivedLetterDate': receivedLetterDate,
    'senderOfficeName': senderOfficeName,
    'subject': subject,
    'targetDepartmentId': targetDepartmentId,
    'targetDepartmentName': targetDepartmentName,
    'targetPersonName': targetPersonName,
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
      targetDepartmentId: map['targetDepartmentId'] as String,
      targetDepartmentName: map['targetDepartmentName'] as String,
      targetPersonName: map['targetPersonName'] as String,
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
    String? targetDepartmentId,
    String? targetDepartmentName,
    String? targetPersonName,
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
  }) {
    return ProductModel(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      receivedLetterNumber: receivedLetterNumber ?? this.receivedLetterNumber,
      receivedLetterDate: receivedLetterDate ?? this.receivedLetterDate,
      senderOfficeName: senderOfficeName ?? this.senderOfficeName,
      subject: subject ?? this.subject,
      targetDepartmentId: targetDepartmentId ?? this.targetDepartmentId,
      targetDepartmentName: targetDepartmentName ?? this.targetDepartmentName,
      targetPersonName: targetPersonName ?? this.targetPersonName,
      productPhotoUrl: productPhotoUrl ?? this.productPhotoUrl,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryPersonContact: deliveryPersonContact ?? this.deliveryPersonContact,
      currentStatus: currentStatus ?? this.currentStatus,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      currentDepartmentId: currentDepartmentId ?? this.currentDepartmentId,
      currentDepartmentName: currentDepartmentName ?? this.currentDepartmentName,
      currentPersonName: currentPersonName ?? this.currentPersonName,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}