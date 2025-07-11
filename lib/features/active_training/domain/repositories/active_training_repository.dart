// domain/repositories/active_training_repository.dart
import '../entities/active_training_session.dart';

abstract class ActiveTrainingRepository {
  Future<void> saveActiveTraining(ActiveTrainingSession session);
}