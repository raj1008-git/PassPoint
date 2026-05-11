// lib/features/events/bloc/invite_state.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_invite_model.dart';

abstract class InviteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InviteInitial extends InviteState {}

class InviteLoading extends InviteState {}

class InviteLoaded extends InviteState {
  final List<EventInviteModel> invites;

  InviteLoaded(this.invites);

  @override
  List<Object?> get props => [invites];
}

class InviteOperationInProgress extends InviteState {
  final List<EventInviteModel> invites;

  InviteOperationInProgress(this.invites);

  @override
  List<Object?> get props => [invites];
}

class InviteOperationSuccess extends InviteState {
  final List<EventInviteModel> invites;
  final String message;

  InviteOperationSuccess(this.invites, this.message);

  @override
  List<Object?> get props => [invites, message];
}

class InviteError extends InviteState {
  final String message;
  final List<EventInviteModel> invites;

  InviteError(this.message, this.invites);

  @override
  List<Object?> get props => [message, invites];
}