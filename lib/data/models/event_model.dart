import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel{
  final String id;
  final String name;
  final String venue;
  final Timestamp eventDate;
  final String description;
  final String status;
  final String createdBy;
  final Timestamp createdAt;

  final int totalInvited;
  final int totalCheckedIn;
  final int totalGiftsDistributed;

  const EventModel({
    required this.id,
    required this.name,
    required this.venue,
    required this.eventDate,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
this.totalInvited=0,
    this.totalCheckedIn=0,
    this.totalGiftsDistributed=0

});
  bool get isDraft=> status =='draft';
  bool get isActive=> status=='active';
  bool get isCompleted=> status=='completed';

  String get statusLabel {
    switch(status){
      case 'draft':
        return 'Draft';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      default:
        return status;

    }
  }
  Map<String,dynamic> toMap()=>{
    'id':id,
    'name':name,
    'venue':venue,
    'eventDate':eventDate,
    'description':description,
    'status':status,
    'createdBy':createdBy,
    'createdAt':createdAt,
    'totalInvited':totalInvited,
    'totalCheckedIn':totalCheckedIn,
    'totalGiftsDistributed':totalGiftsDistributed

  };
  factory EventModel.fromMap(Map<String,dynamic> map){
return EventModel(
  id: map['id'] as String,
  name: map['name'] as String,
  venue: map['venue'] as String,
  eventDate: map['eventDate'] as Timestamp,
  description: map['description'] as String,
  status: map['status'] as String,
  createdBy: map['createdBy'] as String,
  createdAt: map['createdAt'] as Timestamp,
  totalInvited: map['totalInvited'] as int ?? 0,
  totalCheckedIn: map['totalCheckedIn'] as int ?? 0,
  totalGiftsDistributed: map['totalGiftsDistributed'] as int ?? 0,
);
  }
  factory EventModel.fromSnapshot(DocumentSnapshot doc){
  final data =doc.data() as Map<String,dynamic>;
  return EventModel.fromMap(data);

  }
  EventModel copyWith({
    String? id,
    String? name,
    String? venue,
    Timestamp? eventDate,
    String? description,
    String? status,
    String? createdBy,
    Timestamp? createdAt,
    int? totalInvited,
    int? totalCheckedIn,
    int? totalGiftsDistributed,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      venue: venue ?? this.venue,
      eventDate: eventDate ?? this.eventDate,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      totalInvited: totalInvited ?? this.totalInvited,
      totalCheckedIn: totalCheckedIn ?? this.totalCheckedIn,
      totalGiftsDistributed:
      totalGiftsDistributed ?? this.totalGiftsDistributed,
    );
  }

  @override
  String toString() =>
      'EventModel(id: $id, name: $name, status: $status)';
}