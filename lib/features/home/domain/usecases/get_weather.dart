import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetWeather {
  final WeatherRepository repository;

  GetWeather(this.repository);

  Future<WeatherEntity> call() async {
    return await repository.getCurrentWeather();
  }
}
