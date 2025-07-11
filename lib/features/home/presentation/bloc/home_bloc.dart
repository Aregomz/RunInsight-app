import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/usecases/get_weekly_stats.dart';
import '../../domain/usecases/get_weather.dart';
import '../../../user/data/services/user_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetWeeklyStats getWeeklyStats;
  final GetWeather getWeather;

  HomeBloc({
    required this.getWeeklyStats,
    required this.getWeather,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<LoadWeather>(_onLoadWeather);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    
    try {
      print('🔄 Cargando datos del home para usuario ${event.userId}');
      
      // Obtener estadísticas semanales
      WeeklyStatsEntity? weeklyStats;
      try {
        weeklyStats = await getWeeklyStats(event.userId);
      } catch (e) {
        print('⚠️ Error obteniendo estadísticas semanales: $e');
        // Para usuarios nuevos, usar datos por defecto
        weeklyStats = WeeklyStatsEntity(
          totalKm: 0.0,
          totalTrainings: 0,
          avgRhythm: 0.0,
        );
      }
      
      // Obtener datos del usuario (incluyendo insignias)
      Map<String, dynamic> userData;
      int trainingStreak = 0;
      try {
        userData = await UserService.getCurrentUser();
        trainingStreak = userData['stats']?['training_streak'] ?? 0;
      } catch (e) {
        print('⚠️ Error obteniendo datos del usuario: $e');
        // Usar datos por defecto
        userData = {
          'username': 'Usuario',
          'name': 'Usuario',
          'stats': {'training_streak': 0}
        };
      }
      
      emit(HomeLoaded(
        weeklyStats: weeklyStats,
        userData: userData,
        totalBadges: trainingStreak,
      ));
      print('✅ Datos del home cargados exitosamente');
    } catch (e) {
      print('❌ Error crítico al cargar datos del home: $e');
      // En caso de error crítico, mostrar datos por defecto en lugar de error
      emit(HomeLoaded(
        weeklyStats: WeeklyStatsEntity(
          totalKm: 0.0,
          totalTrainings: 0,
          avgRhythm: 0.0,
        ),
        userData: {
          'username': 'Usuario',
          'name': 'Usuario',
          'stats': {'training_streak': 0}
        },
        totalBadges: 0,
      ));
    }
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<HomeState> emit,
  ) async {
    try {
      print('🌤️ Cargando clima para lat: ${event.latitude}, lon: ${event.longitude}');
      final weather = await getWeather();
      
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(weather: weather));
      } else {
        emit(HomeLoaded(weather: weather));
      }
      print('✅ Clima cargado exitosamente');
    } catch (e) {
      print('❌ Error al cargar clima: $e');
      // No emitir error para el clima, solo log
    }
  }
}
