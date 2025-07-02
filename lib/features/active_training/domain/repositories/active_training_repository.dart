// domain/repositories/active_training_repository.dart
import '../entities/active_training_session.dart';

abstract class ActiveTrainingRepository {
  Future<void> startTraining();
  Future<ActiveTrainingSession> endTraining();
  Future<ActiveTrainingSession?> getActiveTraining();
  Future<void> finishTraining();
  Future<ActiveTrainingSession> getSummary();
  Future<void> updateMetrics(ActiveTrainingSession session);
}