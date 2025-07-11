// features/trainings/domain/repositories/trainings_repository.dart
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';

abstract class TrainingsRepository {
  Future<List<TrainingEntity>> getUserTrainings(int userId);
}
