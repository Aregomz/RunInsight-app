import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_future_events.dart';
import '../../domain/entities/event.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetFutureEvents getFutureEvents;

  EventsBloc({required this.getFutureEvents}) : super(EventsInitial()) {
    on<LoadFutureEvents>(_onLoadFutureEvents);
    on<ShowEvent>(_onShowEvent);
    on<DismissEvent>(_onDismissEvent);
  }

  Future<void> _onLoadFutureEvents(
    LoadFutureEvents event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    try {
      final events = await getFutureEvents();
      print('Eventos cargados desde la API en EventsBloc: ${events.length}');
      for (final e in events) {
        print('Evento API: id=${e.id}, fecha=${e.dateEvent}, activo=${e.isCurrentlyActive}');
      }
      emit(EventsLoaded(events: events));
    } catch (e) {
      print('Error al cargar eventos en EventsBloc: $e');
      emit(EventsError(e.toString()));
    }
  }

  void _onShowEvent(
    ShowEvent event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final currentState = state as EventsLoaded;
      final eventToShow = currentState.events.firstWhere(
        (e) => e.id == event.eventId,
        orElse: () => throw Exception('Evento no encontrado'),
      );
      emit(currentState.copyWith(currentEvent: eventToShow));
    }
  }

  void _onDismissEvent(
    DismissEvent event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final currentState = state as EventsLoaded;
      emit(currentState.copyWith(currentEvent: null));
    }
  }
}
