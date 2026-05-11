// lib/features/events/bloc/gift_stock_state.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_gift_model.dart';

abstract class GiftStockState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GiftStockInitial extends GiftStockState {}

class GiftStockLoading extends GiftStockState {}

class GiftStockLoaded extends GiftStockState {
  final List<EventGiftModel> gifts;

  GiftStockLoaded(this.gifts);

  @override
  List<Object?> get props => [gifts];
}

class GiftStockOperationInProgress extends GiftStockState {
  final List<EventGiftModel> gifts;

  GiftStockOperationInProgress(this.gifts);

  @override
  List<Object?> get props => [gifts];
}

class GiftStockOperationSuccess extends GiftStockState {
  final List<EventGiftModel> gifts;
  final String message;

  GiftStockOperationSuccess(this.gifts, this.message);

  @override
  List<Object?> get props => [gifts, message];
}

class GiftStockError extends GiftStockState {
  final String message;
  final List<EventGiftModel> gifts;

  GiftStockError(this.message, this.gifts);

  @override
  List<Object?> get props => [message, gifts];
}