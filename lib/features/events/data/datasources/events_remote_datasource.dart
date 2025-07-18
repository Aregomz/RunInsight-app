import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class EventsRemoteDataSource {
  Future<List<EventModel>> getFutureEvents();
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final Dio dio;

  EventsRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? DioClient.instance;

  @override
  Future<List<EventModel>> getFutureEvents() async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final response = await dio.get(
        '/users/events/by/future',
        queryParameters: {
          'date': formattedDate,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['events'] != null) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson
              .map((eventJson) => EventModel.fromJson(eventJson))
              .toList();
        } else {
          throw Exception('Error en la respuesta del servidor: ${data['message']}');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
} 