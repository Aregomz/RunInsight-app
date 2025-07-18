import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFutureEvents extends EventsEvent {
  const LoadFutureEvents();
}

class ShowEvent extends EventsEvent {
  final int eventId;

  const ShowEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class DismissEvent extends EventsEvent {
  final int eventId;

  const DismissEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
