import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:runinsight/core/config/api_config.dart';

class GeminiService {
  static const String _apiKey = ApiConfig.geminiApiKey;
  late final GenerativeModel _model;

  GeminiService() {
    try {
      print(
        '🤖 Gemini: Inicializando modelo con API key: ${_apiKey.substring(0, 10)}...',
      );
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Cambio a modelo más estable
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      print('✅ Gemini: Modelo inicializado correctamente');
    } catch (e) {
      print('❌ Gemini: Error al inicializar modelo: $e');
    }
  }

  Future<String> generateResponse(String userMessage) async {
    try {
      print('🤖 Gemini: Procesando mensaje: $userMessage');

      final content = [
        Content.text('''
Eres un entrenador personal experto en running y fitness llamado Coach RunInsight. Tu objetivo es ayudar a los usuarios a mejorar su rendimiento deportivo, proporcionar consejos de entrenamiento, analizar su progreso y motivarlos.

Contexto: El usuario está usando una app de running llamada RunInsight que registra entrenamientos, métricas de rendimiento y progreso.

INSTRUCCIONES ESPECÍFICAS:
1. BIENVENIDA DINÁMICA: Si es la primera vez que el usuario escribe, dales una bienvenida personalizada y motivacional. Pregúntales sobre sus objetivos de running.

2. EJERCICIOS Y RUTINAS: Cuando te pregunten sobre ejercicios, rutinas o entrenamientos:
   - Investiga y proporciona información detallada y actualizada
   - Incluye diferentes tipos de ejercicios (cardio, fuerza, flexibilidad)
   - Menciona beneficios específicos de cada ejercicio
   - Considera el nivel del usuario (principiante, intermedio, avanzado)
   - Proporciona variaciones y progresiones
   - Incluye consejos de seguridad y técnica

3. ESTILO DE RESPUESTA:
   - Motivacional y positiva
   - Técnica pero accesible
   - Específica para running y fitness
   - En español
   - Máximo 3-4 frases por respuesta
   - Usa emojis ocasionalmente para hacer la conversación más amigable
   - Sé específico y detallado cuando hables de ejercicios

4. PERSONALIZACIÓN:
   - Adapta las respuestas según el nivel del usuario
   - Considera sus objetivos específicos
   - Proporciona consejos prácticos y aplicables

Mensaje del usuario: $userMessage
'''),
      ];

      print('🤖 Gemini: Enviando request a la API...');
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        print('❌ Gemini: Respuesta vacía de la API');
        return 'Lo siento, no pude procesar tu mensaje. ¿Puedes intentar de nuevo?';
      }

      print('✅ Gemini: Respuesta recibida correctamente');

      // Limpiar asteriscos y otros caracteres no deseados
      final cleanedResponse = _cleanResponse(response.text!);
      print('🧹 Gemini: Respuesta limpia: $cleanedResponse');
      return cleanedResponse;
    } catch (e) {
      print('❌ Gemini: Error al procesar mensaje: $e');
      return 'Hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.';
    }
  }

  String _cleanResponse(String text) {
    return text
        .replaceAll('*', '') // Eliminar asteriscos
        .replaceAll('**', '') // Eliminar dobles asteriscos
        .replaceAll('***', '') // Eliminar triples asteriscos
        .replaceAll('`', '') // Eliminar backticks
        .replaceAll('```', '') // Eliminar bloques de código
        .trim(); // Eliminar espacios extra al inicio y final
  }
}
