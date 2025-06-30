// features/trainings/presentation/bloc/trainings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/trainings/domain/entities/training_entity.dart';
import 'package:runinsight/features/trainings/domain/usecases/get_trainings.dart';

part 'trainings_event.dart';
part 'trainings_state.dart';

class TrainingsBloc extends Bloc<TrainingsEvent, TrainingsState> {
  final GetTrainings getTrainings;

  TrainingsBloc({required this.getTrainings}) : super(TrainingsInitial()) {
    on<LoadTrainings>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTrainings event,
    Emitter<TrainingsState> emit,
  ) async {
    emit(TrainingsLoading());
    try {
      final trainings = await getTrainings();
      emit(TrainingsLoaded(trainings: trainings));
    } catch (_) {
      emit(TrainingsError('Error al cargar entrenamientos'));
    }
  }
}
