// lib/features/events/bloc/gift_stock_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_gift_model.dart';
import '../../../data/repositories/event_gift_repository.dart';
import 'gift_stock_event.dart';
import 'gift_stock_state.dart';

class GiftStockBloc extends Bloc<GiftStockEvent, GiftStockState> {
  final EventGiftRepository _repository;
  StreamSubscription<List<EventGiftModel>>? _giftSubscription;

  GiftStockBloc({EventGiftRepository? repository})
      : _repository = repository ?? EventGiftRepository(),
        super(GiftStockInitial()) {
    on<LoadGiftStock>(_onLoadGiftStock);
    on<AddGift>(_onAddGift);
    on<AddGiftsBulk>(_onAddGiftsBulk);
    on<UpdateGift>(_onUpdateGift);
    on<DeleteGift>(_onDeleteGift);
    on<GiftStockUpdated>(_onGiftStockUpdated);
  }

  // ---------------------------------------------------------------------------
  // Load + subscribe
  // ---------------------------------------------------------------------------

  Future<void> _onLoadGiftStock(
      LoadGiftStock event,
      Emitter<GiftStockState> emit,
      ) async {
    try {
      emit(GiftStockLoading());

      await _giftSubscription?.cancel();

      _giftSubscription = _repository
          .getGiftsStream(event.eventId)
          .listen(
            (gifts) => add(GiftStockUpdated(gifts)),
        onError: (error) {
          devLog(
            'GiftStockBloc stream error',
            params: {'error': error.toString()},
          );
        },
      );
    } catch (e) {
      devLog(
        'GiftStockBloc._onLoadGiftStock error',
        params: {'error': e.toString()},
      );
      emit(GiftStockError(e.toString(), []));
    }
  }

  // ---------------------------------------------------------------------------
  // Add single gift
  // ---------------------------------------------------------------------------

  Future<void> _onAddGift(
      AddGift event,
      Emitter<GiftStockState> emit,
      ) async {
    final currentGifts = _currentGifts;

    try {
      emit(GiftStockOperationInProgress(currentGifts));

      await _repository.addGift(
        eventId: event.eventId,
        name: event.name,
        totalStock: event.totalStock,
      );

      devLog('GiftStockBloc: gift added successfully');
    } catch (e) {
      devLog(
        'GiftStockBloc._onAddGift error',
        params: {'error': e.toString()},
      );
      emit(GiftStockError(e.toString(), currentGifts));
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk add gifts
  // ---------------------------------------------------------------------------

  Future<void> _onAddGiftsBulk(
      AddGiftsBulk event,
      Emitter<GiftStockState> emit,
      ) async {
    final currentGifts = _currentGifts;

    try {
      emit(GiftStockOperationInProgress(currentGifts));

      await _repository.addGiftsBulk(
        eventId: event.eventId,
        gifts: event.gifts,
      );

      devLog(
        'GiftStockBloc: bulk gifts added',
        params: {'count': event.gifts.length},
      );
    } catch (e) {
      devLog(
        'GiftStockBloc._onAddGiftsBulk error',
        params: {'error': e.toString()},
      );
      emit(GiftStockError(e.toString(), currentGifts));
    }
  }

  // ---------------------------------------------------------------------------
  // Update gift
  // ---------------------------------------------------------------------------

  Future<void> _onUpdateGift(
      UpdateGift event,
      Emitter<GiftStockState> emit,
      ) async {
    final currentGifts = _currentGifts;

    try {
      emit(GiftStockOperationInProgress(currentGifts));

      await _repository.updateGift(
        giftId: event.giftId,
        name: event.name,
        totalStock: event.totalStock,
      );

      devLog('GiftStockBloc: gift updated');
    } catch (e) {
      devLog(
        'GiftStockBloc._onUpdateGift error',
        params: {'error': e.toString()},
      );
      emit(GiftStockError(e.toString(), currentGifts));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete gift
  // ---------------------------------------------------------------------------

  Future<void> _onDeleteGift(
      DeleteGift event,
      Emitter<GiftStockState> emit,
      ) async {
    final currentGifts = _currentGifts;

    try {
      emit(GiftStockOperationInProgress(currentGifts));
      await _repository.deleteGift(event.giftId);
      devLog('GiftStockBloc: gift deleted');
    } catch (e) {
      devLog(
        'GiftStockBloc._onDeleteGift error',
        params: {'error': e.toString()},
      );
      emit(GiftStockError(e.toString(), currentGifts));
    }
  }

  // ---------------------------------------------------------------------------
  // Internal stream update — mirrors ProductBloc pattern exactly
  // ---------------------------------------------------------------------------

  Future<void> _onGiftStockUpdated(
      GiftStockUpdated event,
      Emitter<GiftStockState> emit,
      ) async {
    if (state is GiftStockOperationInProgress) {
      emit(GiftStockOperationSuccess(
        event.gifts,
        'Operation completed successfully',
      ));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) emit(GiftStockLoaded(event.gifts));
    } else {
      emit(GiftStockLoaded(event.gifts));
    }
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  List<EventGiftModel> get _currentGifts {
    final s = state;
    if (s is GiftStockLoaded) return s.gifts;
    if (s is GiftStockOperationInProgress) return s.gifts;
    if (s is GiftStockOperationSuccess) return s.gifts;
    if (s is GiftStockError) return s.gifts;
    return [];
  }

  @override
  Future<void> close() {
    _giftSubscription?.cancel();
    return super.close();
  }
}