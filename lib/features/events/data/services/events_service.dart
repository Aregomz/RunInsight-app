import '../../domain/entities/event.dart';

class EventsService {
  // Obtener eventos activos para mostrar
  static List<Event> getActiveEvents(List<Event> allEvents) {
    return allEvents.where((event) => event.isCurrentlyActive).toList();
  }

  // Obtener el primer evento activo (para mostrar)
  static Event? getFirstActiveEvent(List<Event> allEvents) {
    final activeEvents = getActiveEvents(allEvents);
    return activeEvents.isNotEmpty ? activeEvents.first : null;
  }

  // Verificar si hay eventos activos para mostrar
  static bool hasActiveEvents(List<Event> events) {
    return events.any((event) => event.isCurrentlyActive);
  }
} 