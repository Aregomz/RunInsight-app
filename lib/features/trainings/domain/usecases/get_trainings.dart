// features/trainings/domain/usecases/get_trainings.dart
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:runinsight/features/trainings/domain/repositories/trainings_repository.dart';

class GetTrainings {
  final TrainingRepository repository;

  GetTrainings(this.repository);

  Future<List<TrainingEntity>> call() {
    return repository.getTrainings();
  }
}