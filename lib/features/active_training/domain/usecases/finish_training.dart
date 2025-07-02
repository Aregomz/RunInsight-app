import '../repositories/active_training_repository.dart';

class FinishTraining {
  final ActiveTrainingRepository repository;

  FinishTraining(this.repository);

  Future<void> call() async {
    await repository.finishTraining();
  }
}
