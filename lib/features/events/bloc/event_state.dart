// lib/features/events/bloc/event_state.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_model.dart';

abstract class EventState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventModel> events;

  EventLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventOperationInProgress extends EventState {
  final List<EventModel> events;

  EventOperationInProgress(this.events);

  @override
  List<Object?> get props => [events];
}

class EventOperationSuccess extends EventState {
  final List<EventModel> events;
  final String message;

  EventOperationSuccess(this.events, this.message);

  @override
  List<Object?> get props => [events, message];
}

class EventError extends EventState {
  final String message;
  final List<EventModel> events;

  EventError(this.message, this.events);

  @override
  List<Object?> get props => [message, events];
}