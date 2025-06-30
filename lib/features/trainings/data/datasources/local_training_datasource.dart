// features/trainings/data/datasources/local_training_datasource.dart
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';

class LocalTrainingDatasource {
  final List<TrainingEntity> _mockTrainings = [
    TrainingEntity(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      kilometers: 6.2,
      time: '00:34:42',
      pace: '5:35',
      duration: '00:34:42',
      weather: 'Soleado',
      heartRate: 134,
      calories: 290,
    ),
    TrainingEntity(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      kilometers: 5.4,
      time: '00:32:24',
      pace: '6:00',
      duration: '00:32:24',
      weather: 'Nublado',
      heartRate: 128,
      calories: 270,
    ),
  ];

  Future<List<TrainingEntity>> getAllTrainings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTrainings;
  }

  Future<TrainingEntity?> getTrainingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockTrainings.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}