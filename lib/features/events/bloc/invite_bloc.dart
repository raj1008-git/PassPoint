// lib/features/events/bloc/invite_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_invite_model.dart';
import '../../../data/repositories/invite_repository.dart';
import 'invite_event.dart';
import 'invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final InviteRepository _repository;
  StreamSubscription<List<EventInviteModel>>? _inviteSubscription;

  InviteBloc({InviteRepository? repository})
      : _repository = repository ?? InviteRepository(),
        super(InviteInitial()) {
    on<LoadInvites>(_onLoadInvites);
    on<CreateInvite>(_onCreateInvite);
    on<DeleteInvite>(_onDeleteInvite);
    on<SendBulkQrEmails>(_onSendBulkQrEmails);
    on<InvitesUpdated>(_onInvitesUpdated);
  }

  // ---------------------------------------------------------------------------
  // Load + subscribe
  // ---------------------------------------------------------------------------

  Future<void> _onLoadInvites(
      LoadInvites event,
      Emitter<InviteState> emit,
      ) async {
    try {
      emit(InviteLoading());

      await _inviteSubscription?.cancel();

      _inviteSubscription = _repository
          .getInvitesStream(event.eventId)
          .listen(
            (invites) => add(InvitesUpdated(invites)),
        onError: (error) {
          devLog(
            'InviteBloc stream error',
            params: {'error': error.toString()},
          );
        },
      );
    } catch (e) {
      devLog('InviteBloc._onLoadInvites error', params: {'error': e.toString()});
      emit(InviteError(e.toString(), []));
    }
  }

  // ---------------------------------------------------------------------------
  // Create invite
  // ---------------------------------------------------------------------------

  Future<void> _onCreateInvite(
      CreateInvite event,
      Emitter<InviteState> emit,
      ) async {
    final currentInvites = _currentInvites;

    try {
      emit(InviteOperationInProgress(currentInvites));

      await _repository.createInvite(
        eventId: event.eventId,
        eventName: event.eventName,
        eventDate: event.eventDate,
        eventVenue: event.eventVenue,
        phone: event.phone,
        name: event.name,
        email: event.email,
        isPmlilStaff: event.isPmlilStaff,
        branchName: event.branchName,
        departmentName: event.departmentName,
        selectedGifts: event.selectedGifts,
      );

      devLog('InviteBloc: invite created successfully');
    } catch (e) {
      devLog('InviteBloc._onCreateInvite error', params: {'error': e.toString()});
      emit(InviteError(e.toString(), currentInvites));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete invite
  // ---------------------------------------------------------------------------

  Future<void> _onDeleteInvite(
      DeleteInvite event,
      Emitter<InviteState> emit,
      ) async {
    final currentInvites = _currentInvites;

    try {
      emit(InviteOperationInProgress(currentInvites));
      await _repository.deleteInvite(event.inviteId);
      devLog('InviteBloc: invite deleted');
    } catch (e) {
      devLog('InviteBloc._onDeleteInvite error', params: {'error': e.toString()});
      emit(InviteError(e.toString(), currentInvites));
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk QR send
  // ---------------------------------------------------------------------------

  Future<void> _onSendBulkQrEmails(
      SendBulkQrEmails event,
      Emitter<InviteState> emit,
      ) async {
    final currentInvites = _currentInvites;

    try {
      emit(InviteOperationInProgress(currentInvites));

      final result = await _repository.sendBulkQrEmails(event.eventId);

      final sent = result['sent'] as int? ?? 0;
      final failed = result['failed'] as int? ?? 0;

      devLog(
        'InviteBloc: bulk QR send complete',
        params: {'sent': sent, 'failed': failed},
      );

      // Surface result via success message — stream will reload list
      emit(InviteOperationSuccess(
        currentInvites,
        'QR emails sent: $sent${failed > 0 ? ', failed: $failed' : ''}',
      ));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) emit(InviteLoaded(currentInvites));
    } catch (e) {
      devLog(
        'InviteBloc._onSendBulkQrEmails error',
        params: {'error': e.toString()},
      );
      emit(InviteError(e.toString(), currentInvites));
    }
  }

  // ---------------------------------------------------------------------------
  // Internal stream update — mirrors ProductBloc pattern exactly
  // ---------------------------------------------------------------------------

  Future<void> _onInvitesUpdated(
      InvitesUpdated event,
      Emitter<InviteState> emit,
      ) async {
    if (state is InviteOperationInProgress) {
      emit(InviteOperationSuccess(event.invites, 'Operation completed successfully'));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) emit(InviteLoaded(event.invites));
    } else {
      emit(InviteLoaded(event.invites));
    }
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  List<EventInviteModel> get _currentInvites {
    final s = state;
    if (s is InviteLoaded) return s.invites;
    if (s is InviteOperationInProgress) return s.invites;
    if (s is InviteOperationSuccess) return s.invites;
    if (s is InviteError) return s.invites;
    return [];
  }

  @override
  Future<void> close() {
    _inviteSubscription?.cancel();
    return super.close();
  }
}