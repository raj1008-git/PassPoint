import 'package:cloud_firestore/cloud_firestore.dart';

// =============================================================================
// Sub-model — AssignedGift
// Stored as an element inside event_invites.assignedGifts array.
// =============================================================================

class AssignedGift {
  final String giftId;
  final String giftName;
  final bool received;
  final Timestamp? receivedAt;
  final String? notReceivedReason;

  const AssignedGift({
    required this.giftId,
    required this.giftName,
    this.received = false,
    this.receivedAt,
    this.notReceivedReason,
  });

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() => {
    'giftId': giftId,
    'giftName': giftName,
    'received': received,
    'receivedAt': receivedAt,
    'notReceivedReason': notReceivedReason,
  };

  factory AssignedGift.fromMap(Map<String, dynamic> map) {
    return AssignedGift(
      giftId: map['giftId'] as String,
      giftName: map['giftName'] as String,
      received: map['received'] as bool? ?? false,
      receivedAt: map['receivedAt'] as Timestamp?,
      notReceivedReason: map['notReceivedReason'] as String?,
    );
  }

  AssignedGift copyWith({
    String? giftId,
    String? giftName,
    bool? received,
    Timestamp? receivedAt,
    String? notReceivedReason,
  }) {
    return AssignedGift(
      giftId: giftId ?? this.giftId,
      giftName: giftName ?? this.giftName,
      received: received ?? this.received,
      receivedAt: receivedAt ?? this.receivedAt,
      notReceivedReason: notReceivedReason ?? this.notReceivedReason,
    );
  }

  @override
  String toString() =>
      'AssignedGift(giftId: $giftId, name: $giftName, received: $received)';
}

// =============================================================================
// Main model — EventInviteModel
// Mirrors the `event_invites/{inviteId}` Firestore document.
// =============================================================================

class EventInviteModel {
  final String id;

  // Event context — denormalised for offline/scanner use
  final String eventId;
  final String eventName;
  final Timestamp eventDate;
  final String eventVenue;

  // Invitee identity
  final String phone;
  final String name;
  final String email;
  final bool isPmlilStaff;
  final String? branchName;
  final String? departmentName;

  // Gifts
  final List<AssignedGift> assignedGifts;

  // QR lifecycle
  final String? qrToken;
  final String? qrImageUrl;
  final bool qrEmailSent;
  final Timestamp? qrEmailSentAt;

  // Attendance
  final String attendanceStatus; // "pending" | "checked_in" | "checked_out"
  final Timestamp? checkInTime;
  final Timestamp? checkOutTime;

  final Timestamp createdAt;

  const EventInviteModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventVenue,
    required this.phone,
    required this.name,
    required this.email,
    required this.isPmlilStaff,
    this.branchName,
    this.departmentName,
    this.assignedGifts = const [],
    this.qrToken,
    this.qrImageUrl,
    this.qrEmailSent = false,
    this.qrEmailSentAt,
    this.attendanceStatus = 'pending',
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  bool get isPending => attendanceStatus == 'pending';
  bool get isCheckedIn => attendanceStatus == 'checked_in';
  bool get isCheckedOut => attendanceStatus == 'checked_out';

  /// True when a QR has been generated and the download URL is available.
  bool get hasQr => qrToken != null && qrImageUrl != null;

  /// Number of gifts actually received.
  int get receivedGiftCount =>
      assignedGifts.where((g) => g.received).length;

  /// True when every assigned gift has been marked received or declined.
  bool get allGiftsSettled =>
      assignedGifts.isNotEmpty &&
          assignedGifts.every((g) => g.received || g.notReceivedReason != null);

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() => {
    'id': id,
    'eventId': eventId,
    'eventName': eventName,
    'eventDate': eventDate,
    'eventVenue': eventVenue,
    'phone': phone,
    'name': name,
    'email': email,
    'isPmlilStaff': isPmlilStaff,
    'branchName': branchName,
    'departmentName': departmentName,
    'assignedGifts': assignedGifts.map((g) => g.toMap()).toList(),
    'qrToken': qrToken,
    'qrImageUrl': qrImageUrl,
    'qrEmailSent': qrEmailSent,
    'qrEmailSentAt': qrEmailSentAt,
    'attendanceStatus': attendanceStatus,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'createdAt': createdAt,
  };

  factory EventInviteModel.fromMap(Map<String, dynamic> map) {
    return EventInviteModel(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      eventName: map['eventName'] as String,
      eventDate: map['eventDate'] as Timestamp,
      eventVenue: map['eventVenue'] as String,
      phone: map['phone'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      isPmlilStaff: map['isPmlilStaff'] as bool? ?? false,
      branchName: map['branchName'] as String?,
      departmentName: map['departmentName'] as String?,
      assignedGifts: (map['assignedGifts'] as List<dynamic>? ?? [])
          .map((e) => AssignedGift.fromMap(e as Map<String, dynamic>))
          .toList(),
      qrToken: map['qrToken'] as String?,
      qrImageUrl: map['qrImageUrl'] as String?,
      qrEmailSent: map['qrEmailSent'] as bool? ?? false,
      qrEmailSentAt: map['qrEmailSentAt'] as Timestamp?,
      attendanceStatus: map['attendanceStatus'] as String? ?? 'pending',
      checkInTime: map['checkInTime'] as Timestamp?,
      checkOutTime: map['checkOutTime'] as Timestamp?,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  factory EventInviteModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventInviteModel.fromMap(data);
  }

  EventInviteModel copyWith({
    String? id,
    String? eventId,
    String? eventName,
    Timestamp? eventDate,
    String? eventVenue,
    String? phone,
    String? name,
    String? email,
    bool? isPmlilStaff,
    String? branchName,
    String? departmentName,
    List<AssignedGift>? assignedGifts,
    String? qrToken,
    String? qrImageUrl,
    bool? qrEmailSent,
    Timestamp? qrEmailSentAt,
    String? attendanceStatus,
    Timestamp? checkInTime,
    Timestamp? checkOutTime,
    Timestamp? createdAt,
  }) {
    return EventInviteModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      eventVenue: eventVenue ?? this.eventVenue,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      isPmlilStaff: isPmlilStaff ?? this.isPmlilStaff,
      branchName: branchName ?? this.branchName,
      departmentName: departmentName ?? this.departmentName,
      assignedGifts: assignedGifts ?? this.assignedGifts,
      qrToken: qrToken ?? this.qrToken,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
      qrEmailSent: qrEmailSent ?? this.qrEmailSent,
      qrEmailSentAt: qrEmailSentAt ?? this.qrEmailSentAt,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'EventInviteModel(id: $id, name: $name, status: $attendanceStatus)';
}