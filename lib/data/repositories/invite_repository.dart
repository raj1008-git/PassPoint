// lib/data/repositories/invite_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/dev.log.dart';
import '../models/event_invite_model.dart';
import '../models/event_gift_model.dart';
import 'event_gift_repository.dart';
import 'event_repository.dart';

class InviteRepository {
  final FirebaseFirestore _firestore;
  final EventRepository _eventRepository;
  final EventGiftRepository _giftRepository;

  InviteRepository({
    FirebaseFirestore? firestore,
    EventRepository? eventRepository,
    EventGiftRepository? giftRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _eventRepository = eventRepository ?? EventRepository(),
        _giftRepository = giftRepository ?? EventGiftRepository();

  // ---------------------------------------------------------------------------
  // Internal reference helper
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('event_invites');

  // ---------------------------------------------------------------------------
  // Create invite
  // Atomically reserves stock for each assigned gift, saves the invite doc,
  // increments event.totalInvited, then triggers QR generation via Cloud Function.
  // Returns the new invite id.
  // ---------------------------------------------------------------------------

  Future<String> createInvite({
    required String eventId,
    required String eventName,
    required DateTime eventDate,
    required String eventVenue,
    required String phone,
    required String name,
    required String email,
    required bool isPmlilStaff,
    String? branchName,
    String? departmentName,
    required List<EventGiftModel> selectedGifts,
  }) async {
    try {
      devLog(
        'InviteRepository.createInvite',
        params: {'eventId': eventId, 'name': name},
      );

      // Reserve stock for each gift before writing the invite doc
      for (final gift in selectedGifts) {
        await _giftRepository.reserveStock(gift.id);
      }

      final id = const Uuid().v4();
      final now = Timestamp.now();

      final assignedGifts = selectedGifts
          .map((g) => AssignedGift(giftId: g.id, giftName: g.name))
          .toList();

      final invite = EventInviteModel(
        id: id,
        eventId: eventId,
        eventName: eventName,
        eventDate: Timestamp.fromDate(eventDate),
        eventVenue: eventVenue,
        phone: phone.trim(),
        name: name.trim(),
        email: email.trim(),
        isPmlilStaff: isPmlilStaff,
        branchName: branchName?.trim(),
        departmentName: departmentName?.trim(),
        assignedGifts: assignedGifts,
        createdAt: now,
      );

      await _col.doc(id).set(invite.toMap());

      // Increment event counter
      await _eventRepository.incrementInvited(eventId);

      devLog('InviteRepository.createInvite success', params: {'id': id});

      // Trigger QR generation + email (non-blocking — failures logged only)
      _triggerQrGeneration(inviteId: id, eventId: eventId);

      return id;
    } catch (e) {
      devLog(
        'InviteRepository.createInvite error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Trigger QR generation via Cloud Function (fire-and-forget)
  // The Cloud Function updates qrToken, qrImageUrl, qrEmailSent on the doc.
  // ---------------------------------------------------------------------------

  void _triggerQrGeneration({
    required String inviteId,
    required String eventId,
  }) {
    FirebaseFunctions.instanceFor(region: 'asia-south1')
        .httpsCallable('generateAndEmailQr')
        .call({'inviteId': inviteId, 'eventId': eventId}).then((_) {
      devLog(
        'InviteRepository._triggerQrGeneration success',
        params: {'inviteId': inviteId},
      );
    }).catchError((e) {
      devLog(
        'InviteRepository._triggerQrGeneration error',
        params: {'error': e.toString()},
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Bulk send QR emails — calls Cloud Function for all pending in event
  // Returns a map with 'sent' and 'failed' counts.
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> sendBulkQrEmails(String eventId) async {
    try {
      devLog(
        'InviteRepository.sendBulkQrEmails',
        params: {'eventId': eventId},
      );

      final result = await FirebaseFunctions.instanceFor(region: 'asia-south1')
          .httpsCallable('sendBulkQrEmails')
          .call({'eventId': eventId});

      devLog(
        'InviteRepository.sendBulkQrEmails success',
        params: {'result': result.data.toString()},
      );

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      devLog(
        'InviteRepository.sendBulkQrEmails error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SCANNER — Scan 1 (Entry / Check-in)
  // Looks up qrToken, validates, returns the invite for confirmation UI.
  // Does NOT commit check-in yet — caller confirms via confirmCheckIn().
  // ---------------------------------------------------------------------------

  Future<EventInviteModel> resolveQrToken(String qrToken) async {
    try {
      devLog(
        'InviteRepository.resolveQrToken',
        params: {'qrToken': qrToken},
      );

      final snapshot = await _col
          .where('qrToken', isEqualTo: qrToken)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Invalid QR code — invite not found');
      }

      final invite = EventInviteModel.fromSnapshot(snapshot.docs.first);

      if (invite.isCheckedOut) {
        throw Exception('QR already used — this invitee has checked out');
      }

      return invite;
    } catch (e) {
      devLog(
        'InviteRepository.resolveQrToken error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SCANNER — Confirm check-in (Scan 1 → commit)
  // ---------------------------------------------------------------------------

  Future<void> confirmCheckIn(String inviteId) async {
    try {
      devLog(
        'InviteRepository.confirmCheckIn',
        params: {'inviteId': inviteId},
      );

      final doc = await _col.doc(inviteId).get();
      if (!doc.exists) throw Exception('Invite not found: $inviteId');

      final invite = EventInviteModel.fromSnapshot(doc);

      if (invite.isCheckedIn) {
        throw Exception('Invitee is already checked in');
      }
      if (invite.isCheckedOut) {
        throw Exception('QR already used — invitee has checked out');
      }

      final now = Timestamp.now();

      await _col.doc(inviteId).update({
        'attendanceStatus': 'checked_in',
        'checkInTime': now,
      });

      // Increment event counter
      await _eventRepository.incrementCheckedIn(invite.eventId);

      devLog('InviteRepository.confirmCheckIn success');
    } catch (e) {
      devLog(
        'InviteRepository.confirmCheckIn error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SCANNER — Confirm gift collection + check-out (Scan 2 → commit)
  //
  // giftOutcomes: map of giftId → ({received, reason})
  // Marks each gift received/not-received, sets attendanceStatus = checked_out,
  // then increments event.totalGiftsDistributed by the received count.
  // ---------------------------------------------------------------------------

  Future<void> confirmGiftCollectionAndCheckOut({
    required String inviteId,
    required Map<String, ({bool received, String? reason})> giftOutcomes,
  }) async {
    try {
      devLog(
        'InviteRepository.confirmGiftCollectionAndCheckOut',
        params: {'inviteId': inviteId},
      );

      final doc = await _col.doc(inviteId).get();
      if (!doc.exists) throw Exception('Invite not found: $inviteId');

      final invite = EventInviteModel.fromSnapshot(doc);

      if (!invite.isCheckedIn) {
        throw Exception('Cannot check out — invitee is not checked in');
      }

      final now = Timestamp.now();
      int receivedCount = 0;

      final updatedGifts = invite.assignedGifts.map((g) {
        final outcome = giftOutcomes[g.giftId];
        if (outcome == null) return g;

        if (outcome.received) {
          receivedCount++;
          return g.copyWith(received: true, receivedAt: now);
        } else {
          return g.copyWith(
            received: false,
            notReceivedReason: outcome.reason ?? 'Declined',
          );
        }
      }).toList();

      await _col.doc(inviteId).update({
        'assignedGifts': updatedGifts.map((g) => g.toMap()).toList(),
        'attendanceStatus': 'checked_out',
        'checkOutTime': now,
      });

      if (receivedCount > 0) {
        await _eventRepository.incrementGiftsDistributed(
          invite.eventId,
          receivedCount,
        );
      }

      devLog(
        'InviteRepository.confirmGiftCollectionAndCheckOut success',
        params: {'receivedCount': receivedCount},
      );
    } catch (e) {
      devLog(
        'InviteRepository.confirmGiftCollectionAndCheckOut error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time stream — all invites for an event
  // Powers event_detail_screen invitee list via InviteBloc
  // ---------------------------------------------------------------------------

  Stream<List<EventInviteModel>> getInvitesStream(String eventId) {
    return _col
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventInviteModel.fromSnapshot(doc))
        .toList());
  }

  // ---------------------------------------------------------------------------
  // Real-time stream — single invite (scanner confirmation screen live updates)
  // ---------------------------------------------------------------------------

  Stream<EventInviteModel?> getInviteStream(String inviteId) {
    return _col.doc(inviteId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EventInviteModel.fromSnapshot(doc);
    });
  }

  // ---------------------------------------------------------------------------
  // One-time fetch — used by export screen
  // ---------------------------------------------------------------------------

  Future<List<EventInviteModel>> getInvitesOnce(String eventId) async {
    try {
      devLog(
        'InviteRepository.getInvitesOnce',
        params: {'eventId': eventId},
      );

      final snapshot = await _col
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventInviteModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      devLog(
        'InviteRepository.getInvitesOnce error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete invite — releases gift stock for each assigned gift
  // ---------------------------------------------------------------------------

  Future<void> deleteInvite(String inviteId) async {
    try {
      devLog('InviteRepository.deleteInvite', params: {'inviteId': inviteId});

      final doc = await _col.doc(inviteId).get();
      if (!doc.exists) return;

      final invite = EventInviteModel.fromSnapshot(doc);

      // Release stock for every assigned gift
      for (final gift in invite.assignedGifts) {
        await _giftRepository.releaseStock(gift.giftId);
      }

      await _col.doc(inviteId).delete();

      devLog('InviteRepository.deleteInvite success');
    } catch (e) {
      devLog(
        'InviteRepository.deleteInvite error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }
}