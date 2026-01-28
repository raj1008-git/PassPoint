import 'package:equatable/equatable.dart';

abstract class StaffApprovalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load pending staff
class LoadPendingStaff extends StaffApprovalEvent {}

// Approve staff
class ApproveStaff extends StaffApprovalEvent {
  final String userId;

  ApproveStaff(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Reject staff
class RejectStaff extends StaffApprovalEvent {
  final String userId;

  RejectStaff(this.userId);

  @override
  List<Object?> get props => [userId];
}
