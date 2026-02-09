import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String id;
  final String name;
  final String code; // Short code (e.g., "HQ", "POK", "BTL")
  final bool isHeadquarter;
  final bool hasDepartments; // Only HQ has departments
  final bool hasReceptionist; // Only HQ has receptionist
  final Timestamp createdAt;

  BranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isHeadquarter,
    required this.hasDepartments,
    required this.hasReceptionist,
    required this.createdAt,
  });

  // Convenience getters
  bool get isKamaladi => code == 'HQ';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'isHeadquarter': isHeadquarter,
    'hasDepartments': hasDepartments,
    'hasReceptionist': hasReceptionist,
    'createdAt': createdAt,
  };

  factory BranchModel.fromMap(Map<String, dynamic> map, String docId) {
    return BranchModel(
      id: docId,
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      isHeadquarter: map['isHeadquarter'] as bool? ?? false,
      hasDepartments: map['hasDepartments'] as bool? ?? false,
      hasReceptionist: map['hasReceptionist'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory BranchModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BranchModel.fromMap(data, doc.id);
  }

  BranchModel copyWith({
    String? id,
    String? name,
    String? code,
    bool? isHeadquarter,
    bool? hasDepartments,
    bool? hasReceptionist,
    Timestamp? createdAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isHeadquarter: isHeadquarter ?? this.isHeadquarter,
      hasDepartments: hasDepartments ?? this.hasDepartments,
      hasReceptionist: hasReceptionist ?? this.hasReceptionist,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
