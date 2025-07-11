import '../../domain/entities/active_training_session.dart';
import '../../domain/repositories/active_training_repository.dart';
import '../datasources/active_training_remote_datasource.dart';
import '../models/active_training_request_model.dart';

class ActiveTrainingRepositoryImpl implements ActiveTrainingRepository {
  final ActiveTrainingRemoteDatasource remoteDatasource;
  ActiveTrainingRepositoryImpl({ActiveTrainingRemoteDatasource? remoteDatasource})
      : remoteDatasource = remoteDatasource ?? ActiveTrainingRemoteDatasourceImpl();

  @override
  Future<void> saveActiveTraining(ActiveTrainingSession session) async {
    final request = ActiveTrainingRequestModel(
      timeMinutes: session.timeMinutes,
      distanceKm: session.distanceKm,
      rhythm: session.rhythm,
      date: session.date,
      altitude: session.altitude,
      notes: session.notes,
      trainingType: session.trainingType,
      terrainType: session.terrainType,
      weather: session.weather,
    );
    await remoteDatasource.sendActiveTraining(request);
  }
} 