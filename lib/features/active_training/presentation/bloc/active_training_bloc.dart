// features/active_training/presentation/bloc/active_training_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'active_training_event.dart';
import 'active_training_state.dart';
import '../../domain/entities/active_training_session.dart';
import '../../domain/usecases/save_active_training.dart';

class ActiveTrainingBloc extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final SaveActiveTraining saveActiveTraining;

  // Datos temporales del entrenamiento
  int _timeMinutes = 0;
  double _distanceKm = 0.0;
  double _rhythm = 0.0;
  double _altitude = 0.0;
  String _weather = '';

  ActiveTrainingBloc({required this.saveActiveTraining}) : super(ActiveTrainingInitial()) {
    on<StartTraining>((event, emit) {
      // Resetear datos
      _timeMinutes = 0;
      _distanceKm = 0.0;
      _rhythm = 0.0;
      _altitude = 0.0;
      _weather = '';
      emit(ActiveTrainingInProgress(
        timeMinutes: _timeMinutes,
        distanceKm: _distanceKm,
        rhythm: _rhythm,
        altitude: _altitude,
        weather: _weather,
      ));
    });

    on<UpdateTrainingData>((event, emit) {
      _timeMinutes = event.timeMinutes;
      _distanceKm = event.distanceKm;
      _rhythm = event.rhythm;
      _altitude = event.altitude;
      _weather = event.weather;
      emit(ActiveTrainingInProgress(
        timeMinutes: _timeMinutes,
        distanceKm: _distanceKm,
        rhythm: _rhythm,
        altitude: _altitude,
        weather: _weather,
      ));
    });

    on<FinishTraining>((event, emit) async {
      emit(ActiveTrainingSaving());
      try {
        // Usar el tiempo real del entrenamiento (en minutos)
        final realTimeMinutes = event.realTimeMinutes ?? _timeMinutes;
        
        // Calcular el ritmo real basado en el tiempo real
        final realRhythm = _distanceKm > 0 ? realTimeMinutes / _distanceKm : 0.0;
        
        // Formatear fecha como YYYY-MM-DD
        final now = DateTime.now();
        final dateString = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        
        print('🏃 Finalizando entrenamiento:');
        print('   Tiempo real: ${realTimeMinutes} minutos');
        print('   Distancia: ${_distanceKm} km');
        print('   Ritmo: ${realRhythm.toStringAsFixed(1)} min/km');
        print('   Fecha: $dateString');
        print('   Tipo: ${event.trainingType}');
        print('   Terreno: ${event.terrainType}');
        print('   Clima: $_weather');
        
        final session = ActiveTrainingSession(
          timeMinutes: realTimeMinutes,
          distanceKm: _distanceKm,
          rhythm: realRhythm,
          date: dateString,
          altitude: _altitude,
          notes: event.notes,
          trainingType: event.trainingType,
          terrainType: event.terrainType,
          weather: _weather,
        );
        
        await saveActiveTraining(session);
        emit(ActiveTrainingSuccess(
          timeMinutes: realTimeMinutes,
          distanceKm: _distanceKm,
          rhythm: realRhythm,
          altitude: _altitude,
          weather: _weather,
          trainingType: event.trainingType,
          terrainType: event.terrainType,
          notes: event.notes,
          date: dateString,
        ));
      } catch (e) {
        print('❌ Error finalizando entrenamiento: $e');
        emit(ActiveTrainingFailure(e.toString()));
      }
    });

    on<ResetTraining>((event, emit) {
      _timeMinutes = 0;
      _distanceKm = 0.0;
      _rhythm = 0.0;
      _altitude = 0.0;
      _weather = '';
      emit(ActiveTrainingInitial());
    });
  }
}
