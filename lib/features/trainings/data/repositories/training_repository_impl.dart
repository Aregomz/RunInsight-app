// features/trainings/data/repositories/training_repository_impl.dart
import 'package:runinsight/features/trainings/data/datasources/local_training_datasource.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:runinsight/features/trainings/domain/repositories/trainings_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final LocalTrainingDatasource datasource;

  TrainingRepositoryImpl(this.datasource);

  @override
  Future<List<TrainingEntity>> getTrainings() {
    return datasource.getAllTrainings();
  }
}