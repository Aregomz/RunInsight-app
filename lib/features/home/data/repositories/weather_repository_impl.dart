import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import 'dart:developer' as developer;
import 'package:geocoding/geocoding.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource datasource;

  WeatherRepositoryImpl({WeatherRemoteDatasource? datasource})
      : datasource = datasource ?? WeatherRemoteDatasource();

  @override
  Future<WeatherEntity> getCurrentWeather() async {
    try {
      developer.log('🌤️ Iniciando obtención del clima con Weatherbit...');

      // Obtener ubicación actual del usuario
      developer.log('📍 Obteniendo ubicación actual...');
      final position = await datasource.getCurrentLocation();
      developer.log(
        '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );

      // Obtener clima desde Weatherbit API
      developer.log('🌐 Conectando con Weatherbit API...');
      final weatherResponse = await datasource.fetchWeatherData(
        position.latitude,
        position.longitude,
      );
      developer.log('🌐 Datos del clima obtenidos: ${weatherResponse.data.toString()}');

      // Obtener nombre de la ciudad
      developer.log('🏙️ Obteniendo nombre de la ciudad...');
      final cityName = await _getCityName(
        position.latitude,
        position.longitude,
      );
      developer.log('🏙️ Ciudad: $cityName');

      final weatherData = weatherResponse.data[0];
      final weather = WeatherEntity(
        condition: _getWeatherCondition(
          weatherData.weather.code,
        ),
        temperature: weatherData.temp.round(),
        city: cityName,
        rainProbability: _getRainProbability(weatherData),
      );

      developer.log(
        '✅ Clima procesado exitosamente: ${weather.condition}, ${weather.temperature}°C, ${weather.city}',
      );
      return weather;
    } catch (e) {
      developer.log('❌ Error al obtener clima: $e');
      // En caso de error, retornar datos por defecto
      return WeatherEntity(
        condition: 'Clima perfecto',
        temperature: 22,
        city: 'Tu ciudad',
        rainProbability: 20,
      );
    }
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final city = placemarks.first.locality ?? 'Tu ciudad';
        developer.log('🏙️ Ciudad obtenida: $city');
        return city;
      }
    } catch (e) {
      developer.log('❌ Error al obtener nombre de ciudad: $e');
    }
    return 'Tu ciudad';
  }

  String _getWeatherCondition(int code) {
    // Weatherbit weather codes: https://www.weatherbit.io/api/codes
    if (code >= 200 && code < 300) return 'Tormenta';
    if (code >= 300 && code < 400) return 'Llovizna';
    if (code >= 400 && code < 500) return 'Lluvia';
    if (code >= 500 && code < 600) return 'Lluvia';
    if (code >= 600 && code < 700) return 'Nevado';
    if (code >= 700 && code < 800) return 'Niebla';
    if (code == 800) return 'Clima perfecto';
    if (code >= 801 && code < 900) return 'Parcialmente nublado';
    return 'Clima perfecto';
  }

  int _getRainProbability(dynamic weatherData) {
    developer.log('🌧️ Buscando probabilidad de lluvia en: $weatherData');

    // Intentar diferentes campos donde puede estar la probabilidad de lluvia
    if (weatherData.pop != null) {
      final pop = weatherData.pop;
      developer.log('🌧️ Probabilidad de lluvia encontrada en pop: $pop');
      return pop is int ? pop : pop.round();
    }

    if (weatherData.precip != null) {
      final precip = weatherData.precip;
      developer.log('🌧️ Probabilidad de lluvia encontrada en precip: $precip');
      return precip is int ? precip : precip.round();
    }

    // Si no hay datos de probabilidad, calcular basado en el código del clima
    final weatherCode = weatherData.weather.code;
    if (weatherCode != null) {
      final probability = _calculateRainProbabilityFromCode(weatherCode);
      developer.log(
        '🌧️ Probabilidad calculada desde código $weatherCode: $probability%',
      );
      return probability;
    }

    developer.log('🌧️ No se encontró probabilidad de lluvia, usando 0%');
    return 0;
  }

  int _calculateRainProbabilityFromCode(int code) {
    if (code >= 200 && code < 300) return 90; // Tormenta
    if (code >= 300 && code < 400) return 70; // Llovizna
    if (code >= 400 && code < 500) return 80; // Lluvia
    if (code >= 500 && code < 600) return 85; // Lluvia
    if (code >= 600 && code < 700) return 60; // Nevado
    if (code >= 700 && code < 800) return 30; // Niebla
    if (code == 800) return 0; // Clima perfecto
    if (code >= 801 && code < 900) return 20; // Parcialmente nublado
    return 0;
  }
}
