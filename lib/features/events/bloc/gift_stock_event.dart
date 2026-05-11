// lib/features/events/bloc/gift_stock_event.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_gift_model.dart';

abstract class GiftStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load and subscribe to all gifts for a given event
class LoadGiftStock extends GiftStockEvent {
  final String eventId;

  LoadGiftStock(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// Add a single gift type
class AddGift extends GiftStockEvent {
  final String eventId;
  final String name;
  final int totalStock;

  AddGift({
    required this.eventId,
    required this.name,
    required this.totalStock,
  });

  @override
  List<Object?> get props => [eventId, name, totalStock];
}

// Add multiple gift types at once
class AddGiftsBulk extends GiftStockEvent {
  final String eventId;
  final List<({String name, int totalStock})> gifts;

  AddGiftsBulk({required this.eventId, required this.gifts});

  @override
  List<Object?> get props => [eventId, gifts];
}

// Update a gift's name or totalStock
class UpdateGift extends GiftStockEvent {
  final String giftId;
  final String? name;
  final int? totalStock;

  UpdateGift({required this.giftId, this.name, this.totalStock});

  @override
  List<Object?> get props => [giftId, name, totalStock];
}

// Delete a gift (only if assignedCount == 0)
class DeleteGift extends GiftStockEvent {
  final String giftId;

  DeleteGift(this.giftId);

  @override
  List<Object?> get props => [giftId];
}

// Internal — fired by stream listener
class GiftStockUpdated extends GiftStockEvent {
  final List<EventGiftModel> gifts;

  GiftStockUpdated(this.gifts);

  @override
  List<Object?> get props => [gifts];
}