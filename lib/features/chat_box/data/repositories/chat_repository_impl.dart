// features/chat_box/data/repositories_impl/chat_repository_impl.dart
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import 'package:runinsight/features/chat_box/domain/repositories/chat_repository.dart';
import 'package:runinsight/core/services/gemini_api_service.dart';
import '../datasources/chat_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiApiService geminiApiService;
  final int userId;
  late final ChatStorageService _storageService;

  ChatRepositoryImpl({required this.geminiApiService, required this.userId}) {
    _storageService = ChatStorageService(userId);
  }

  @override
  Future<List<ChatMessage>> sendMessage(String message) async {
    try {
      // Cargar mensajes existentes
      final existingMessages = await _storageService.loadMessages();
      print(
        '📥 Mensajes existentes en repositorio:  [90m${existingMessages.length} [0m',
      );

      // Crear mensaje del usuario
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Guardar mensaje del usuario inmediatamente
      final messagesWithUser = [...existingMessages, userMessage];
      await _storageService.saveMessages(messagesWithUser);
      print('💾 Mensaje del usuario guardado');

      // Determinar si es la primera vez que el usuario escribe
      final isFirstMessage = existingMessages.isEmpty;
      print('🎯 Es primera vez: $isFirstMessage');

      // Generar respuesta usando Gemini con contexto
      print('🔄 Repositorio: Llamando a Gemini...');
      String aiResponse;

      if (isFirstMessage) {
        // Para el primer mensaje, dar bienvenida personalizada
        aiResponse = await geminiApiService.generateResponse(
          'Primera vez: $message',
        );
      } else {
        // Para mensajes posteriores, incluir contexto de la conversación
        final recentMessages = existingMessages
            .skip(existingMessages.length > 4 ? existingMessages.length - 4 : 0)
            .map((m) => '${m.isUser ? "Usuario" : "Coach"}: ${m.content}')
            .join('\n');
        aiResponse = await geminiApiService.generateResponse(
          'Contexto anterior:\n$recentMessages\n\nNuevo mensaje: $message',
        );
      }

      print('✅ Repositorio: Respuesta de Gemini recibida');

      // Crear mensaje de la IA
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Agregar mensaje de la IA y guardar todo
      final allMessages = [...messagesWithUser, aiMessage];
      await _storageService.saveMessages(allMessages);
      print('💾 Guardados ${allMessages.length} mensajes total');

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

  // Limpiar historial de chat
  Future<void> clearChat({int? userId}) async {
    await _storageService.clearMessages();
  }

  // Método de debug para verificar almacenamiento
  Future<void> debugStorage({int? userId}) async {
    await _storageService.debugStorage();
  }
}
