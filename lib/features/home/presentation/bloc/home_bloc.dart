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
      final weeklyStats = await getWeeklyStats(event.userId);
      
      // Obtener datos del usuario (incluyendo insignias)
      final userData = await UserService.getCurrentUser();
      final trainingStreak = userData['stats']?['training_streak'] ?? 0;
      
      emit(HomeLoaded(
        weeklyStats: weeklyStats,
        userData: userData,
        totalBadges: trainingStreak,
      ));
      print('✅ Datos del home cargados exitosamente');
    } catch (e) {
      print('❌ Error al cargar datos del home: $e');
      emit(HomeError(message: e.toString()));
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
