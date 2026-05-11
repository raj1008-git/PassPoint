// lib/features/events/bloc/event_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repository;
  StreamSubscription<List<EventModel>>? _eventSubscription;

  EventBloc({EventRepository? repository})
      : _repository = repository ?? EventRepository(),
        super(EventInitial()) {
    on<LoadAllEvents>(_onLoadAllEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<ActivateEvent>(_onActivateEvent);
    on<CompleteEvent>(_onCompleteEvent);
    on<EventsUpdated>(_onEventsUpdated);
  }

  // ---------------------------------------------------------------------------
  // Load + subscribe
  // ---------------------------------------------------------------------------

  Future<void> _onLoadAllEvents(
      LoadAllEvents event,
      Emitter<EventState> emit,
      ) async {
    try {
      emit(EventLoading());

      await _eventSubscription?.cancel();

      _eventSubscription = _repository.getAllEventsStream().listen(
            (events) => add(EventsUpdated(events)),
        onError: (error) {
          devLog(
            'EventBloc stream error',
            params: {'error': error.toString()},
          );
        },
      );
    } catch (e) {
      devLog('EventBloc._onLoadAllEvents error', params: {'error': e.toString()});
      emit(EventError(e.toString(), []));
    }
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> _onCreateEvent(
      CreateEvent event,
      Emitter<EventState> emit,
      ) async {
    final currentEvents = _currentEvents;

    try {
      emit(EventOperationInProgress(currentEvents));

      await _repository.createEvent(
        name: event.name,
        venue: event.venue,
        eventDate: event.eventDate,
        description: event.description,
        createdByUid: event.createdByUid,
      );

      devLog('EventBloc: event created successfully');
    } catch (e) {
      devLog('EventBloc._onCreateEvent error', params: {'error': e.toString()});
      emit(EventError(e.toString(), currentEvents));
    }
  }

  // ---------------------------------------------------------------------------
  // Update metadata
  // ---------------------------------------------------------------------------

  Future<void> _onUpdateEvent(
      UpdateEvent event,
      Emitter<EventState> emit,
      ) async {
    final currentEvents = _currentEvents;

    try {
      emit(EventOperationInProgress(currentEvents));

      await _repository.updateEvent(
        eventId: event.eventId,
        name: event.name,
        venue: event.venue,
        eventDate: event.eventDate,
        description: event.description,
      );

      devLog('EventBloc: event updated successfully');
    } catch (e) {
      devLog('EventBloc._onUpdateEvent error', params: {'error': e.toString()});
      emit(EventError(e.toString(), currentEvents));
    }
  }

  // ---------------------------------------------------------------------------
  // Activate
  // ---------------------------------------------------------------------------

  Future<void> _onActivateEvent(
      ActivateEvent event,
      Emitter<EventState> emit,
      ) async {
    final currentEvents = _currentEvents;

    try {
      emit(EventOperationInProgress(currentEvents));
      await _repository.activateEvent(event.eventId);
      devLog('EventBloc: event activated');
    } catch (e) {
      devLog('EventBloc._onActivateEvent error', params: {'error': e.toString()});
      emit(EventError(e.toString(), currentEvents));
    }
  }

  // ---------------------------------------------------------------------------
  // Complete
  // ---------------------------------------------------------------------------

  Future<void> _onCompleteEvent(
      CompleteEvent event,
      Emitter<EventState> emit,
      ) async {
    final currentEvents = _currentEvents;

    try {
      emit(EventOperationInProgress(currentEvents));
      await _repository.completeEvent(event.eventId);
      devLog('EventBloc: event completed');
    } catch (e) {
      devLog('EventBloc._onCompleteEvent error', params: {'error': e.toString()});
      emit(EventError(e.toString(), currentEvents));
    }
  }

  // ---------------------------------------------------------------------------
  // Internal stream update — mirrors ProductBloc pattern exactly
  // OperationInProgress → OperationSuccess (500ms) → Loaded
  // ---------------------------------------------------------------------------

  Future<void> _onEventsUpdated(
      EventsUpdated event,
      Emitter<EventState> emit,
      ) async {
    if (state is EventOperationInProgress) {
      emit(EventOperationSuccess(event.events, 'Operation completed successfully'));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) emit(EventLoaded(event.events));
    } else {
      emit(EventLoaded(event.events));
    }
  }

  // ---------------------------------------------------------------------------
  // Helper — extract current list regardless of state
  // ---------------------------------------------------------------------------

  List<EventModel> get _currentEvents {
    final s = state;
    if (s is EventLoaded) return s.events;
    if (s is EventOperationInProgress) return s.events;
    if (s is EventOperationSuccess) return s.events;
    if (s is EventError) return s.events;
    return [];
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
} 