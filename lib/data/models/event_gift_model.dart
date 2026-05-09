import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the `event_gifts/{giftId}` Firestore document.
/// Represents a single gift type within an event, with live stock tracking.
class EventGiftModel {
  final String id;
  final String eventId;
  final String name;
  final int totalStock;
  final int assignedCount;
  final int remainingStock;
  final Timestamp createdAt;

  const EventGiftModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.totalStock,
    required this.assignedCount,
    required this.remainingStock,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  bool get isOutOfStock => remainingStock <= 0;
  bool get isLowStock => remainingStock > 0 && remainingStock <= 10;

  /// Percentage of stock still available (0.0 – 1.0).
  double get stockFraction =>
      totalStock == 0 ? 0.0 : remainingStock / totalStock;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() => {
    'id': id,
    'eventId': eventId,
    'name': name,
    'totalStock': totalStock,
    'assignedCount': assignedCount,
    'remainingStock': remainingStock,
    'createdAt': createdAt,
  };

  factory EventGiftModel.fromMap(Map<String, dynamic> map) {
    return EventGiftModel(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      name: map['name'] as String,
      totalStock: map['totalStock'] as int? ?? 0,
      assignedCount: map['assignedCount'] as int? ?? 0,
      remainingStock: map['remainingStock'] as int? ?? 0,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  factory EventGiftModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventGiftModel.fromMap(data);
  }

  EventGiftModel copyWith({
    String? id,
    String? eventId,
    String? name,
    int? totalStock,
    int? assignedCount,
    int? remainingStock,
    Timestamp? createdAt,
  }) {
    return EventGiftModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      totalStock: totalStock ?? this.totalStock,
      assignedCount: assignedCount ?? this.assignedCount,
      remainingStock: remainingStock ?? this.remainingStock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'EventGiftModel(id: $id, name: $name, remaining: $remainingStock/$totalStock)';
}