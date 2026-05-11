// lib/data/repositories/event_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/dev.log.dart';
import '../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Internal reference helper
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('events');

  // ---------------------------------------------------------------------------
  // Create event
  // Returns the newly created event's id.
  // ---------------------------------------------------------------------------

  Future<String> createEvent({
    required String name,
    required String venue,
    required DateTime eventDate,
    required String description,
    required String createdByUid,
  }) async {
    try {
      devLog('EventRepository.createEvent', params: {'name': name});

      final id = const Uuid().v4();
      final now = Timestamp.now();

      final event = EventModel(
        id: id,
        name: name.trim(),
        venue: venue.trim(),
        eventDate: Timestamp.fromDate(eventDate),
        description: description.trim(),
        status: 'draft',
        createdBy: createdByUid,
        createdAt: now,
      );

      await _col.doc(id).set(event.toMap());

      devLog('EventRepository.createEvent success', params: {'id': id});
      return id;
    } catch (e) {
      devLog(
        'EventRepository.createEvent error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Update event metadata (name / venue / date / description)
  // Status transitions use dedicated methods below.
  // ---------------------------------------------------------------------------

  Future<void> updateEvent({
    required String eventId,
    String? name,
    String? venue,
    DateTime? eventDate,
    String? description,
  }) async {
    try {
      devLog('EventRepository.updateEvent', params: {'eventId': eventId});

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (venue != null) updates['venue'] = venue.trim();
      if (eventDate != null) {
        updates['eventDate'] = Timestamp.fromDate(eventDate);
      }
      if (description != null) updates['description'] = description.trim();

      if (updates.isEmpty) return;

      await _col.doc(eventId).update(updates);

      devLog('EventRepository.updateEvent success');
    } catch (e) {
      devLog(
        'EventRepository.updateEvent error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Status transitions
  // ---------------------------------------------------------------------------

  Future<void> activateEvent(String eventId) async {
    try {
      devLog('EventRepository.activateEvent', params: {'eventId': eventId});
      await _col.doc(eventId).update({'status': 'active'});
    } catch (e) {
      devLog(
        'EventRepository.activateEvent error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> completeEvent(String eventId) async {
    try {
      devLog('EventRepository.completeEvent', params: {'eventId': eventId});
      await _col.doc(eventId).update({'status': 'completed'});
    } catch (e) {
      devLog(
        'EventRepository.completeEvent error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Increment counters atomically
  // Called by invite_repository after check-in / gift distribution.
  // ---------------------------------------------------------------------------

  Future<void> incrementCheckedIn(String eventId) async {
    try {
      await _col.doc(eventId).update({
        'totalCheckedIn': FieldValue.increment(1),
      });
    } catch (e) {
      devLog(
        'EventRepository.incrementCheckedIn error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> incrementGiftsDistributed(String eventId, int count) async {
    try {
      await _col.doc(eventId).update({
        'totalGiftsDistributed': FieldValue.increment(count),
      });
    } catch (e) {
      devLog(
        'EventRepository.incrementGiftsDistributed error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> incrementInvited(String eventId) async {
    try {
      await _col.doc(eventId).update({
        'totalInvited': FieldValue.increment(1),
      });
    } catch (e) {
      devLog(
        'EventRepository.incrementInvited error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time stream — all events ordered by eventDate descending
  // Powers event_dashboard_screen via EventBloc
  // ---------------------------------------------------------------------------

  Stream<List<EventModel>> getAllEventsStream() {
    return _col
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromSnapshot(doc)).toList());
  }

  // ---------------------------------------------------------------------------
  // Real-time stream — single event (for event_detail_screen live updates)
  // ---------------------------------------------------------------------------

  Stream<EventModel?> getEventStream(String eventId) {
    return _col.doc(eventId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EventModel.fromSnapshot(doc);
    });
  }

  // ---------------------------------------------------------------------------
  // One-time fetch — used by scanner to resolve eventId context
  // ---------------------------------------------------------------------------

  Future<EventModel?> getEventOnce(String eventId) async {
    try {
      devLog('EventRepository.getEventOnce', params: {'eventId': eventId});

      final doc = await _col.doc(eventId).get();
      if (!doc.exists) return null;

      return EventModel.fromSnapshot(doc);
    } catch (e) {
      devLog(
        'EventRepository.getEventOnce error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }
}