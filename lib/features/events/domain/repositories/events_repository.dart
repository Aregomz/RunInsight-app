import '../entities/event.dart';

abstract class EventsRepository {
  Future<List<Event>> getFutureEvents();
} 