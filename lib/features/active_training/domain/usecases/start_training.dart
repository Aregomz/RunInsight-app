import '../repositories/active_training_repository.dart';

class StartTraining {
  final ActiveTrainingRepository repository;

  StartTraining(this.repository);

  Future<void> call() async {
    await repository.startTraining();
  }
}
