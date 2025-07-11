import '../entities/active_training_session.dart';
import '../repositories/active_training_repository.dart';

class SaveActiveTraining {
  final ActiveTrainingRepository repository;
  SaveActiveTraining(this.repository);

  Future<void> call(ActiveTrainingSession session) async {
    await repository.saveActiveTraining(session);
  }
} 