import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetFutureEvents {
  final EventsRepository repository;

  GetFutureEvents(this.repository);

  Future<List<Event>> call() async {
    return await repository.getFutureEvents();
  }
} 