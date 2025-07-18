import '../../domain/repositories/events_repository.dart';
import '../../domain/entities/event.dart';
import '../datasources/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;

  EventsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Event>> getFutureEvents() async {
    try {
      final events = await remoteDataSource.getFutureEvents();
      return events.where((event) => event.isCurrentlyActive).toList();
    } catch (e) {
      throw Exception('Error al obtener eventos: $e');
    }
  }
} 