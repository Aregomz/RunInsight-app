// features/trainings/domain/usecases/get_user_trainings.dart
import '../entities/training_entity.dart';
import '../repositories/trainings_repository.dart';

class GetUserTrainings {
  final TrainingsRepository repository;

  GetUserTrainings(this.repository);

  Future<List<TrainingEntity>> call(int userId) async {
    return await repository.getUserTrainings(userId);
  }
} 