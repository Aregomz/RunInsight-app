// features/trainings/presentation/bloc/trainings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/training_entity.dart';
import '../../domain/usecases/get_user_trainings.dart';
import 'trainings_event.dart';
import 'trainings_state.dart';

class TrainingsBloc extends Bloc<TrainingsEvent, TrainingsState> {
  final GetUserTrainings getUserTrainings;

  TrainingsBloc({required this.getUserTrainings}) : super(TrainingsInitial()) {
    on<LoadUserTrainings>(_onLoadUserTrainings);
  }

  Future<void> _onLoadUserTrainings(
    LoadUserTrainings event,
    Emitter<TrainingsState> emit,
  ) async {
    emit(TrainingsLoading());
    
    try {
      print('🔄 Cargando entrenamientos del usuario ${event.userId}');
      final trainings = await getUserTrainings(event.userId);
      emit(TrainingsLoaded(trainings: trainings));
      print('✅ ${trainings.length} entrenamientos cargados exitosamente');
    } catch (e) {
      print('❌ Error al cargar entrenamientos: $e');
      emit(TrainingsError(message: e.toString()));
    }
  }
}
