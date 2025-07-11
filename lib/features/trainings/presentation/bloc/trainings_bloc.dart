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
      // Verificar si el ID de usuario es válido
      if (event.userId <= 0) {
        print('❌ ID de usuario inválido: ${event.userId}');
        emit(TrainingsError(message: 'Sesión expirada. Inicia sesión nuevamente.'));
        return;
      }
      
      print('🔄 Cargando entrenamientos del usuario ${event.userId}');
      final trainings = await getUserTrainings(event.userId);
      emit(TrainingsLoaded(trainings: trainings));
      print('✅ ${trainings.length} entrenamientos cargados exitosamente');
    } catch (e) {
      print('❌ Error al cargar entrenamientos: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      print('❌ Mensaje completo: ${e.toString()}');
      
      // Para la mayoría de errores, asumir que es un usuario nuevo sin datos
      // y mostrar lista vacía en lugar de error
      if (e.toString().contains('timeout') || 
          e.toString().contains('connection') ||
          e.toString().contains('network')) {
        // Solo errores de red reales muestran error
        print('🌐 Error de conexión real detectado');
        emit(TrainingsError(message: 'Error de conexión. Verifica tu internet.'));
      } else if (e.toString().contains('401') || 
                 e.toString().contains('403')) {
        // Error de autenticación
        print('🔐 Error de autenticación detectado');
        emit(TrainingsError(message: 'Sesión expirada. Inicia sesión nuevamente.'));
      } else {
        // Para cualquier otro error, asumir que es un usuario sin datos
        print('📝 Asumiendo usuario sin entrenamientos, mostrando lista vacía');
        emit(TrainingsLoaded(trainings: []));
      }
    }
  }
}
