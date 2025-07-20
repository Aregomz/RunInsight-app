// features/chat_box/data/repositories_impl/chat_repository_impl.dart
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import 'package:runinsight/features/chat_box/domain/repositories/chat_repository.dart';
import 'package:runinsight/core/services/gemini_api_service.dart';
import '../datasources/chat_local_datasource.dart';
import '../repositories/question_classification_repository_impl.dart';
import '../services/chat_cleanup_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiApiService geminiApiService;
  final int userId;
  late final ChatStorageService _storageService;
  late final QuestionClassificationRepositoryImpl _classificationRepository;

  ChatRepositoryImpl({required this.geminiApiService, required this.userId}) {
    _storageService = ChatStorageService(userId);
    _classificationRepository = QuestionClassificationRepositoryImpl();
  }

  @override
  Future<List<ChatMessage>> sendMessage(String message) async {
    try {
      // Verificar si debe limpiar el historial automáticamente
      await _checkAndPerformCleanup();
      
      // Enviar pregunta al backend para clasificación automática
      print('🚀🚀🚀 INICIANDO CLASIFICACIÓN PARA: "$message" 🚀🚀🚀');
      print('🔍 Enviando pregunta al backend para clasificación...');
      print('💬 Mensaje original: "$message"');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      
      final classification = await _classificationRepository.classifyQuestion(message);
      print('📊 Backend clasificó la pregunta como: ${classification.category ?? "sin clasificar"}');
      print('🔗 Integración completada exitosamente');
      print('✅✅✅ CLASIFICACIÓN COMPLETADA PARA: "$message" ✅✅✅');

      // Crear mensaje del usuario
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Agregar mensaje del usuario sin cargar todos los mensajes
      await _storageService.addMessage(userMessage);
      print('💾 Mensaje del usuario guardado');

      // Cargar solo los últimos 4 mensajes para el contexto (más eficiente)
      final recentMessages = await _storageService.loadMessages();
      final isFirstMessage = recentMessages.length <= 1; // Solo el mensaje que acabamos de agregar
      print('🎯 Es primera vez: $isFirstMessage');

      // Generar respuesta usando Gemini con contexto
      print('🔄 Repositorio: Llamando a Gemini...');
      String aiResponse;

      // Incluir la categoría en el contexto si está disponible
      final categoryContext = classification.category != null 
          ? '\nCategoría de la pregunta: ${classification.category}'
          : '';
      
      print('🏷️ Contexto de categoría agregado: ${categoryContext.isNotEmpty ? categoryContext : "ninguno"}');

      if (isFirstMessage) {
        // Para el primer mensaje, dar bienvenida personalizada
        final prompt = 'Primera vez: $message$categoryContext';
        print('🤖 Prompt para Gemini (primera vez): $prompt');
        aiResponse = await geminiApiService.generateResponse(prompt);
      } else {
        // Para mensajes posteriores, incluir contexto de la conversación (solo últimos 4)
        final contextMessages = recentMessages
            .skip(recentMessages.length > 4 ? recentMessages.length - 4 : 0)
            .map((m) => '${m.isUser ? "Usuario" : "Coach"}: ${m.content}')
            .join('\n');
        final prompt = 'Contexto anterior:\n$contextMessages\n\nNuevo mensaje: $message$categoryContext';
        print('🤖 Prompt para Gemini (con contexto): $prompt');
        aiResponse = await geminiApiService.generateResponse(prompt);
      }

      print('✅ Repositorio: Respuesta de Gemini recibida');

      // Crear mensaje de la IA
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Agregar mensaje de la IA
      await _storageService.addMessage(aiMessage);
      print('💾 Mensaje de IA guardado');

      return [userMessage, aiMessage];
    } catch (e) {
      print('❌ Error en sendMessage: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      // En caso de error, crear mensaje de error
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Guardar mensajes de error
      final existingMessages = await _storageService.loadMessages();
      final allMessages = [...existingMessages, userMessage, errorMessage];
      await _storageService.saveMessages(allMessages);

      return [userMessage, errorMessage];
    }
  }

  // Cargar mensajes guardados
  Future<List<ChatMessage>> loadMessages({int? userId}) async {
    try {
      final messages = await _storageService.loadMessages();
      print('🔄 Repositorio cargó  [90m${messages.length} [0m mensajes');
      return messages;
    } catch (e) {
      print('❌ Error en repositorio al cargar: $e');
      return [];
    }
  }

  // Cargar solo los últimos N mensajes (más eficiente)
  Future<List<ChatMessage>> loadRecentMessages({int? userId, int limit = 10}) async {
    try {
      final allMessages = await _storageService.loadMessages();
      final recentMessages = allMessages.length > limit 
          ? allMessages.skip(allMessages.length - limit).toList()
          : allMessages;
      print('🔄 Repositorio cargó  [90m${recentMessages.length} [0m mensajes recientes (de ${allMessages.length} total)');
      return recentMessages;
    } catch (e) {
      print('❌ Error en repositorio al cargar mensajes recientes: $e');
      return [];
    }
  }

  // Limpiar historial de chat
  Future<void> clearChat({int? userId}) async {
    await _storageService.clearMessages();
  }

  // Método de debug para verificar almacenamiento
  Future<void> debugStorage({int? userId}) async {
    await _storageService.debugStorage();
  }
  
  /// Verifica y ejecuta la limpieza automática si es necesario
  Future<void> _checkAndPerformCleanup() async {
    try {
      final isEnabled = await ChatCleanupService.isCleanupEnabled();
      if (!isEnabled) {
        print('🔧 Limpieza automática deshabilitada');
        return;
      }
      
      final shouldCleanup = await ChatCleanupService.shouldCleanup();
      if (shouldCleanup) {
        print('🧹 Ejecutando limpieza automática del historial...');
        await ChatCleanupService.performCleanup(userId);
      }
    } catch (e) {
      print('❌ Error al verificar limpieza automática: $e');
    }
  }
}
