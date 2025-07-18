import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  final Event? currentEvent;

  const EventsLoaded({
    required this.events,
    this.currentEvent,
  });

  @override
  List<Object?> get props => [events, currentEvent];

  EventsLoaded copyWith({
    List<Event>? events,
    Event? currentEvent,
  }) {
    return EventsLoaded(
      events: events ?? this.events,
      currentEvent: currentEvent ?? this.currentEvent,
    );
  }
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
