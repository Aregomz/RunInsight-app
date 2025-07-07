import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  static const String _apiKey = 'b608d9642fea4d118f5f680968e47e8a';
  static const String _baseUrl = 'https://api.weatherbit.io/v2.0';

  @override
  Future<WeatherEntity> getCurrentWeather() async {
    try {
      developer.log('🌤️ Iniciando obtención del clima con Weatherbit...');

      // Obtener ubicación actual del usuario
      developer.log('📍 Obteniendo ubicación actual...');
      final position = await _getCurrentLocation();
      developer.log(
        '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );

      // Obtener clima desde Weatherbit API
      developer.log('🌐 Conectando con Weatherbit API...');
      final weatherData = await _fetchWeatherData(
        position.latitude,
        position.longitude,
      );
      developer.log('🌐 Datos del clima obtenidos: ${weatherData.toString()}');

      // Obtener nombre de la ciudad
      developer.log('🏙️ Obteniendo nombre de la ciudad...');
      final cityName = await _getCityName(
        position.latitude,
        position.longitude,
      );
      developer.log('🏙️ Ciudad: $cityName');

      final weather = WeatherEntity(
        condition: _getWeatherCondition(
          weatherData['data'][0]['weather']['code'],
        ),
        temperature: weatherData['data'][0]['temp'].round(),
        city: cityName,
        rainProbability: _getRainProbability(weatherData['data'][0]),
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

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('❌ Servicios de ubicación deshabilitados');
      throw Exception('Los servicios de ubicación están deshabilitados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      developer.log('🔐 Solicitando permisos de ubicación...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('❌ Permisos de ubicación denegados');
        throw Exception('Permisos de ubicación denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('❌ Permisos de ubicación permanentemente denegados');
      throw Exception(
        'Los permisos de ubicación están permanentemente denegados',
      );
    }

    developer.log('✅ Permisos de ubicación concedidos');
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _fetchWeatherData(double lat, double lon) async {
    final url = '$_baseUrl/current?lat=$lat&lon=$lon&key=$_apiKey&lang=es';
    developer.log('🌐 URL de la API: $url');

    try {
      final response = await http.get(Uri.parse(url));
      developer.log('🌐 Código de respuesta: ${response.statusCode}');
      developer.log('🌐 Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        developer.log(
          '❌ Error HTTP: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Error al obtener datos del clima: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log('❌ Error de conexión: $e');
      throw Exception('Error de conexión: $e');
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

  int _getRainProbability(Map<String, dynamic> weatherData) {
    developer.log('🌧️ Buscando probabilidad de lluvia en: $weatherData');

    // Intentar diferentes campos donde puede estar la probabilidad de lluvia
    if (weatherData['pop'] != null) {
      final pop = weatherData['pop'];
      developer.log('🌧️ Probabilidad de lluvia encontrada en pop: $pop');
      return pop is int ? pop : pop.round();
    }

    if (weatherData['precip'] != null) {
      final precip = weatherData['precip'];
      developer.log('🌧️ Probabilidad de lluvia encontrada en precip: $precip');
      return precip is int ? precip : precip.round();
    }

    // Si no hay datos de probabilidad, calcular basado en el código del clima
    final weatherCode = weatherData['weather']?['code'];
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
