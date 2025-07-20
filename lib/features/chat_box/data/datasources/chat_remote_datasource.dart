import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/question_classification_model.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource();

  /// Envía una pregunta del usuario para clasificación automática
  /// 
  /// El backend se encarga de clasificar la pregunta en una de las 5 categorías:
  /// - nutricion: Preguntas sobre alimentación, suplementos, hidratación
  /// - entrenamiento: Preguntas sobre ejercicios, rutinas, técnicas
  /// - recuperacion: Preguntas sobre descanso, estiramientos, recuperación
  /// - prevencion: Preguntas sobre prevención de lesiones, fortalecimiento
  /// - equipamiento: Preguntas sobre ropa, calzado, tecnología deportiva
  Future<QuestionClassificationModel> classifyQuestion(String question) async {
    try {
      print('🔍 Enviando pregunta al backend: ${question.substring(0, question.length > 50 ? 50 : question.length)}...');
      
      // Log del endpoint completo
      final fullUrl = '${ApiEndpoints.baseUrl}${ApiEndpoints.classifyQuestion}';
      print('🌐 URL completa: $fullUrl');
      
      // Log del payload que se envía
      final payload = {'question': question};
      print('📤 Payload enviado: $payload');
      
      final response = await DioClient.post(
        ApiEndpoints.classifyQuestion,
        data: payload,
      );

      print('✅ Respuesta del backend recibida: ${response.data}');
      print('📊 Status code: ${response.statusCode}');
      print('📋 Headers: ${response.headers}');
      
      return QuestionClassificationModel.fromJson(response.data);
    } catch (e) {
      print('❌ Error al enviar pregunta: $e');
      final errorMessage = DioClient.handleError(e);
      print('❌ Mensaje de error: $errorMessage');
      
      // Log adicional para debugging de errores
      if (e is DioException) {
        print('🔍 Tipo de error Dio: ${e.type}');
        print('🔍 Status code: ${e.response?.statusCode}');
        print('🔍 Response data: ${e.response?.data}');
        print('🔍 Request data: ${e.requestOptions.data}');
      }
      
      // En caso de error, devolver la pregunta sin clasificación
      return QuestionClassificationModel(
        question: question,
        category: null,
      );
    }
  }
} 