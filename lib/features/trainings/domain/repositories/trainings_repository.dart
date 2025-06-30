// features/trainings/domain/repositories/training_repository.dart
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';

abstract class TrainingRepository {
  Future<List<TrainingEntity>> getTrainings();
}
