import 'dart:convert';
import 'package:runinsight/core/services/gemini_api_service.dart';
import '../models/ia_prediction_model.dart';
import 'ia_coach_remote_datasource.dart';

class IaCoachRemoteDatasourceImpl implements IaCoachRemoteDatasource {
  final GeminiApiService geminiApiService;

  IaCoachRemoteDatasourceImpl({required this.geminiApiService});

  @override
  Future<List<IaPredictionModel>> getPredictions({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> lastTrainings,
  }) async {
    final prompt = _buildPrompt(userStats, lastTrainings);
    final response = await geminiApiService.generateResponse(prompt);
    try {
      final jsonListMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);
      if (jsonListMatch != null) {
        final jsonListString = jsonListMatch.group(0)!;
        final List<dynamic> decoded = jsonDecode(jsonListString);
        return decoded.map((e) => IaPredictionModel.fromJson(e)).toList();
      } else {
        // Si no se encuentra un JSON de lista, devuelve error
        return [
          IaPredictionModel(
            type: "error",
            value: 0.0,
            unit: "",
            description: "No se pudo extraer un JSON de lista de la respuesta de IA Coach: $response",
            icon: "❌",
            chartData: [],
          ),
        ];
      }
    } catch (e) {
      // Si la respuesta no es JSON válido, devuelve una predicción de error
      return [
        IaPredictionModel(
          type: "error",
          value: 0.0,
          unit: "",
          description: "No se pudo procesar la respuesta de IA Coach: $response",
          icon: "❌",
          chartData: [],
        ),
      ];
    }
  }

  String _buildPrompt(Map<String, dynamic> userStats, List<Map<String, dynamic>> lastTrainings) {
    return '''
Eres un coach de running. Analiza estas estadísticas y predice el rendimiento del usuario, da consejos personalizados y resume en máximo 3 predicciones clave, cada una con:
- type: tipo de predicción (ej: rendimiento, riesgo de lesión, ritmo futuro)
- value: valor numérico (si aplica)
- unit: unidad (si aplica)
- description: descripción breve
- icon: icono sugerido (emoji)
- chartData: lista de 7 valores para un gráfico de tendencia semanal (si aplica)
- chartExplanation: breve explicación de lo que representa la gráfica (si aplica)
- racePredictions: lista de objetos con los tiempos estimados para carreras de 5km, 10km, 21km y 42km, cada uno con:
    - distance: distancia en km (5, 10, 21, 42)
    - unit: 'km'
    - time: tiempo estimado en formato hh:mm:ss

No incluyas predicciones de motivación ni de salud general. Incluye al menos una predicción sobre el ritmo promedio futuro del usuario para las próximas semanas y una sobre el riesgo de lesión por exceso de carga, basada en la frecuencia de entrenamiento.

Estadísticas usuario: $userStats
Entrenamientos recientes: $lastTrainings
Responde en formato JSON de lista, ejemplo:
[
  {"type": "rendimiento", "value": 10.0, "unit": "km", "description": "Puedes mejorar tu distancia semanal", "icon": "🏃", "chartData": [8, 9, 10, 11, 10, 12, 13], "chartExplanation": "Esta gráfica muestra la evolución de tu distancia semanal en los últimos 7 días.", "racePredictions": [
    {"distance": 5, "unit": "km", "time": "00:28:30"},
    {"distance": 10, "unit": "km", "time": "01:00:00"},
    {"distance": 21, "unit": "km", "time": "02:15:00"},
    {"distance": 42, "unit": "km", "time": "04:50:00"}
  ]},
  {"type": "riesgo de lesión", "value": 30, "unit": "%", "description": "Tu frecuencia de entrenamiento es adecuada, el riesgo de lesión por exceso de carga es bajo.", "icon": "🦵", "chartData": [20, 25, 30, 28, 27, 30, 30], "chartExplanation": "Esta gráfica muestra la evolución estimada de tu riesgo de lesión por exceso de carga en la última semana.", "racePredictions": []},
  {"type": "ritmo futuro", "value": 6.0, "unit": "min/km", "description": "Se espera que tu ritmo promedio mejore a 6 min/km en las próximas semanas.", "icon": "⏱️", "chartData": [7, 6.8, 6.5, 6.3, 6.2, 6.1, 6.0], "chartExplanation": "Predicción de tu ritmo promedio para las próximas semanas.", "racePredictions": []}
]
''';
  }
} 