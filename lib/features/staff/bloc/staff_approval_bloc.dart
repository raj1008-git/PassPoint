import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pass_point/features/staff/bloc/staff_approoval_state.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import 'staff_approval_event.dart';

class StaffApprovalBloc extends Bloc<StaffApprovalEvent, StaffApprovalState> {
  final UserRepository _repository;
  StreamSubscription<List<UserModel>>? _staffSubscription;

  StaffApprovalBloc({UserRepository? repository})
    : _repository = repository ?? UserRepository(),
      super(StaffApprovalInitial()) {
    on<LoadPendingStaff>(_onLoadPendingStaff);
    on<ApproveStaff>(_onApproveStaff);
    on<RejectStaff>(_onRejectStaff);
    on<_PendingStaffUpdated>(_onPendingStaffUpdated);
  }

  Future<void> _onLoadPendingStaff(
    LoadPendingStaff event,
    Emitter<StaffApprovalState> emit,
  ) async {
    try {
      emit(StaffApprovalLoading());

      // Cancel existing subscription
      await _staffSubscription?.cancel();

      // Subscribe to real-time updates
      _staffSubscription = _repository.getPendingStaffStream().listen(
        (pendingStaff) {
          add(_PendingStaffUpdated(pendingStaff));
        },
        onError: (error) {
          devLog(
            'Pending staff stream error',
            params: {'error': error.toString()},
          );
        },
      );
    } catch (e) {
      devLog('Error loading pending staff', params: {'error': e.toString()});
      emit(StaffApprovalError(e.toString(), []));
    }
  }

  Future<void> _onApproveStaff(
    ApproveStaff event,
    Emitter<StaffApprovalState> emit,
  ) async {
    final currentState = state;
    final currentStaff = currentState is StaffApprovalLoaded
        ? currentState.pendingStaff
        : <UserModel>[];

    try {
      emit(StaffApprovalOperationInProgress(currentStaff));

      await _repository.approveStaff(event.userId);

      devLog('Staff approved successfully');
      // Real-time stream will update the list automatically
    } catch (e) {
      devLog('Error approving staff', params: {'error': e.toString()});
      emit(StaffApprovalError(e.toString(), currentStaff));
    }
  }

  Future<void> _onRejectStaff(
    RejectStaff event,
    Emitter<StaffApprovalState> emit,
  ) async {
    final currentState = state;
    final currentStaff = currentState is StaffApprovalLoaded
        ? currentState.pendingStaff
        : <UserModel>[];

    try {
      emit(StaffApprovalOperationInProgress(currentStaff));

      await _repository.rejectStaff(event.userId);

      devLog('Staff rejected successfully');
      // Real-time stream will update the list automatically
    } catch (e) {
      devLog('Error rejecting staff', params: {'error': e.toString()});
      emit(StaffApprovalError(e.toString(), currentStaff));
    }
  }

  Future<void> _onPendingStaffUpdated(
    _PendingStaffUpdated event,
    Emitter<StaffApprovalState> emit,
  ) async {
    final currentState = state;

    if (currentState is StaffApprovalOperationInProgress) {
      // If operation was in progress, show success
      emit(
        StaffApprovalOperationSuccess(
          event.pendingStaff,
          'Operation completed successfully',
        ),
      );
      // After a brief moment, go back to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) {
        emit(StaffApprovalLoaded(event.pendingStaff));
      }
    } else {
      // Just update the list
      emit(StaffApprovalLoaded(event.pendingStaff));
    }
  }

  @override
  Future<void> close() {
    _staffSubscription?.cancel();
    return super.close();
  }
}

// Internal event for real-time updates
class _PendingStaffUpdated extends StaffApprovalEvent {
  final List<UserModel> pendingStaff;

  _PendingStaffUpdated(this.pendingStaff);

  @override
  List<Object?> get props => [pendingStaff];
}
