import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/weather_response_model.dart';

class WeatherRemoteDatasource {
  Future<WeatherResponseModel> fetchWeatherData(double lat, double lon) async {
    final url = ApiEndpoints.weatherbitCurrent(lat, lon);
    developer.log('🌐 URL de la API: $url');

    try {
      final response = await http.get(Uri.parse(url));
      developer.log('🌐 Código de respuesta: ${response.statusCode}');
      developer.log('🌐 Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        return WeatherResponseModel.fromJson(json.decode(response.body));
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

  Future<Position> getCurrentLocation() async {
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
} 