import '../repositories/active_training_repository.dart';
import '../entities/active_training_session.dart';

class UpdateTrainingMetrics {
  final ActiveTrainingRepository repository;

  UpdateTrainingMetrics(this.repository);

  Future<void> call(ActiveTrainingSession session) async {
    await repository.updateMetrics(session);
  }
}
