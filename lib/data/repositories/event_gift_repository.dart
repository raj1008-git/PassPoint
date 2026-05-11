// lib/data/repositories/event_gift_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/dev.log.dart';
import '../models/event_gift_model.dart';

class EventGiftRepository {
  final FirebaseFirestore _firestore;

  EventGiftRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Internal reference helper
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('event_gifts');

  // ---------------------------------------------------------------------------
  // Add a single gift type to an event
  // Returns the new gift's id.
  // ---------------------------------------------------------------------------

  Future<String> addGift({
    required String eventId,
    required String name,
    required int totalStock,
  }) async {
    try {
      devLog(
        'EventGiftRepository.addGift',
        params: {'eventId': eventId, 'name': name, 'totalStock': totalStock},
      );

      final id = const Uuid().v4();
      final now = Timestamp.now();

      final gift = EventGiftModel(
        id: id,
        eventId: eventId,
        name: name.trim(),
        totalStock: totalStock,
        assignedCount: 0,
        remainingStock: totalStock,
        createdAt: now,
      );

      await _col.doc(id).set(gift.toMap());

      devLog('EventGiftRepository.addGift success', params: {'id': id});
      return id;
    } catch (e) {
      devLog(
        'EventGiftRepository.addGift error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk add gifts — used when event manager uploads initial inventory
  // Runs as a single batched write for atomicity.
  // Returns list of generated gift ids in the same order as input.
  // ---------------------------------------------------------------------------

  Future<List<String>> addGiftsBulk({
    required String eventId,
    required List<({String name, int totalStock})> gifts,
  }) async {
    try {
      devLog(
        'EventGiftRepository.addGiftsBulk',
        params: {'eventId': eventId, 'count': gifts.length},
      );

      final batch = _firestore.batch();
      final now = Timestamp.now();
      final ids = <String>[];

      for (final entry in gifts) {
        final id = const Uuid().v4();
        ids.add(id);

        final gift = EventGiftModel(
          id: id,
          eventId: eventId,
          name: entry.name.trim(),
          totalStock: entry.totalStock,
          assignedCount: 0,
          remainingStock: entry.totalStock,
          createdAt: now,
        );

        batch.set(_col.doc(id), gift.toMap());
      }

      await batch.commit();

      devLog(
        'EventGiftRepository.addGiftsBulk success',
        params: {'added': ids.length},
      );
      return ids;
    } catch (e) {
      devLog(
        'EventGiftRepository.addGiftsBulk error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Decrement remainingStock + increment assignedCount atomically
  // Called when a gift is assigned to an invitee.
  // Throws if stock is already 0 to prevent over-assignment.
  // ---------------------------------------------------------------------------

  Future<void> reserveStock(String giftId) async {
    try {
      devLog('EventGiftRepository.reserveStock', params: {'giftId': giftId});

      await _firestore.runTransaction((transaction) async {
        final docRef = _col.doc(giftId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Gift not found: $giftId');
        }

        final gift = EventGiftModel.fromSnapshot(snapshot);

        if (gift.remainingStock <= 0) {
          throw Exception('Gift "${gift.name}" is out of stock');
        }

        transaction.update(docRef, {
          'remainingStock': FieldValue.increment(-1),
          'assignedCount': FieldValue.increment(1),
        });
      });

      devLog('EventGiftRepository.reserveStock success');
    } catch (e) {
      devLog(
        'EventGiftRepository.reserveStock error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Release stock — called if an invite is deleted before check-out
  // ---------------------------------------------------------------------------

  Future<void> releaseStock(String giftId) async {
    try {
      devLog('EventGiftRepository.releaseStock', params: {'giftId': giftId});

      await _col.doc(giftId).update({
        'remainingStock': FieldValue.increment(1),
        'assignedCount': FieldValue.increment(-1),
      });

      devLog('EventGiftRepository.releaseStock success');
    } catch (e) {
      devLog(
        'EventGiftRepository.releaseStock error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Update gift name or totalStock
  // Adjusts remainingStock by the delta when totalStock changes.
  // ---------------------------------------------------------------------------

  Future<void> updateGift({
    required String giftId,
    String? name,
    int? totalStock,
  }) async {
    try {
      devLog('EventGiftRepository.updateGift', params: {'giftId': giftId});

      if (name == null && totalStock == null) return;

      await _firestore.runTransaction((transaction) async {
        final docRef = _col.doc(giftId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) throw Exception('Gift not found: $giftId');

        final gift = EventGiftModel.fromSnapshot(snapshot);
        final updates = <String, dynamic>{};

        if (name != null) updates['name'] = name.trim();

        if (totalStock != null) {
          final delta = totalStock - gift.totalStock;
          final newRemaining = gift.remainingStock + delta;

          if (newRemaining < 0) {
            throw Exception(
              'Cannot reduce totalStock below already-assigned count',
            );
          }

          updates['totalStock'] = totalStock;
          updates['remainingStock'] = newRemaining;
        }

        transaction.update(docRef, updates);
      });

      devLog('EventGiftRepository.updateGift success');
    } catch (e) {
      devLog(
        'EventGiftRepository.updateGift error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete gift — only safe if assignedCount == 0
  // ---------------------------------------------------------------------------

  Future<void> deleteGift(String giftId) async {
    try {
      devLog('EventGiftRepository.deleteGift', params: {'giftId': giftId});

      final doc = await _col.doc(giftId).get();
      if (!doc.exists) return;

      final gift = EventGiftModel.fromSnapshot(doc);
      if (gift.assignedCount > 0) {
        throw Exception(
          'Cannot delete "${gift.name}": already assigned to ${gift.assignedCount} invitee(s)',
        );
      }

      await _col.doc(giftId).delete();

      devLog('EventGiftRepository.deleteGift success');
    } catch (e) {
      devLog(
        'EventGiftRepository.deleteGift error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time stream — all gifts for an event
  // Powers gift_inventory_screen and add_invitee_screen via GiftStockBloc
  // ---------------------------------------------------------------------------

  Stream<List<EventGiftModel>> getGiftsStream(String eventId) {
    return _col
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventGiftModel.fromSnapshot(doc))
        .toList());
  }

  // ---------------------------------------------------------------------------
  // One-time fetch — used by invite_repository when saving invite
  // ---------------------------------------------------------------------------

  Future<List<EventGiftModel>> getGiftsOnce(String eventId) async {
    try {
      devLog(
        'EventGiftRepository.getGiftsOnce',
        params: {'eventId': eventId},
      );

      final snapshot = await _col
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => EventGiftModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      devLog(
        'EventGiftRepository.getGiftsOnce error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }
}