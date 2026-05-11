// lib/features/events/bloc/event_event.dart

import 'package:equatable/equatable.dart';

import '../../../data/models/event_model.dart';

abstract class EventEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load and subscribe to all events stream
class LoadAllEvents extends EventEvent {}

// Create a new event
class CreateEvent extends EventEvent {
  final String name;
  final String venue;
  final DateTime eventDate;
  final String description;
  final String createdByUid;

  CreateEvent({
    required this.name,
    required this.venue,
    required this.eventDate,
    required this.description,
    required this.createdByUid,
  });

  @override
  List<Object?> get props => [name, venue, eventDate, description, createdByUid];
}

// Update event metadata
class UpdateEvent extends EventEvent {
  final String eventId;
  final String? name;
  final String? venue;
  final DateTime? eventDate;
  final String? description;

  UpdateEvent({
    required this.eventId,
    this.name,
    this.venue,
    this.eventDate,
    this.description,
  });

  @override
  List<Object?> get props => [eventId, name, venue, eventDate, description];
}

// Activate a draft event
class ActivateEvent extends EventEvent {
  final String eventId;

  ActivateEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// Mark event as completed
class CompleteEvent extends EventEvent {
  final String eventId;

  CompleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// Internal — fired by stream listener
class EventsUpdated extends EventEvent {
  final List<EventModel> events;

  EventsUpdated(this.events);

  @override
  List<Object?> get props => [events];
}