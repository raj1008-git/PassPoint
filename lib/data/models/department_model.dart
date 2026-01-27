import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final Timestamp createdAt;

  Department({required this.id, required this.name, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt,
  };

  factory Department.fromMap(Map<String, dynamic> map, String docId) {
    return Department(
      id: docId,
      name: map['name'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory Department.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department.fromMap(data, doc.id);
  }
}
