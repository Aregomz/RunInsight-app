import '../repositories/active_training_repository.dart';
import '../entities/active_training_session.dart';

class GetTrainingSummary {
  final ActiveTrainingRepository repository;

  GetTrainingSummary(this.repository);

  Future<ActiveTrainingSession> call() async {
    return repository.getSummary();
  }
}
