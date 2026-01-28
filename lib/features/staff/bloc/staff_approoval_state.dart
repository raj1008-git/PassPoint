import 'package:equatable/equatable.dart';

import '../../../data/models/user_model.dart';

abstract class StaffApprovalState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class StaffApprovalInitial extends StaffApprovalState {}

// Loading state
class StaffApprovalLoading extends StaffApprovalState {}

// Loaded state (with list of pending staff)
class StaffApprovalLoaded extends StaffApprovalState {
  final List<UserModel> pendingStaff;

  StaffApprovalLoaded(this.pendingStaff);

  @override
  List<Object?> get props => [pendingStaff];
}

// Operation in progress (approve/reject)
class StaffApprovalOperationInProgress extends StaffApprovalState {
  final List<UserModel> pendingStaff;

  StaffApprovalOperationInProgress(this.pendingStaff);

  @override
  List<Object?> get props => [pendingStaff];
}

// Operation success
class StaffApprovalOperationSuccess extends StaffApprovalState {
  final List<UserModel> pendingStaff;
  final String message;

  StaffApprovalOperationSuccess(this.pendingStaff, this.message);

  @override
  List<Object?> get props => [pendingStaff, message];
}

// Error state
class StaffApprovalError extends StaffApprovalState {
  final String message;
  final List<UserModel> pendingStaff;

  StaffApprovalError(this.message, this.pendingStaff);

  @override
  List<Object?> get props => [message, pendingStaff];
}
