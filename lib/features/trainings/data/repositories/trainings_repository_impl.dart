// features/trainings/data/repositories/trainings_repository_impl.dart
import '../../domain/entities/training_entity.dart';
import '../../domain/repositories/trainings_repository.dart';
import '../datasources/trainings_remote_datasource.dart';
import '../models/training_response_model.dart';

class TrainingsRepositoryImpl implements TrainingsRepository {
  final TrainingsRemoteDataSource remoteDataSource;

  TrainingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TrainingEntity>> getUserTrainings(int userId) async {
    try {
      print('🔄 Obteniendo entrenamientos del usuario $userId desde el repositorio');
      
      final response = await remoteDataSource.getUserTrainings(userId);
      
      // Convertir modelos a entidades
      final trainings = response.trainings.map((training) => TrainingEntity(
        id: training.id,
        timeMinutes: training.timeMinutes,
        distanceKm: training.distanceKm,
        rhythm: training.rhythm,
        date: training.date,
        altitude: training.altitude,
        notes: training.notes,
        trainingType: training.trainingType,
        terrainType: training.terrainType,
        weather: training.weather,
      )).toList();

      print('✅ ${trainings.length} entrenamientos obtenidos exitosamente');
      return trainings;
    } catch (e) {
      print('❌ Error en el repositorio al obtener entrenamientos: $e');
      throw Exception('Error al obtener entrenamientos: $e');
    }
  }
} 