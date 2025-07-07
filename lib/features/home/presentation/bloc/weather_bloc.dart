import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/usecases/get_weather.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeather getWeather;

  WeatherBloc({required this.getWeather}) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      final weather = await getWeather();
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError('Error al cargar el clima'));
    }
  }
}
