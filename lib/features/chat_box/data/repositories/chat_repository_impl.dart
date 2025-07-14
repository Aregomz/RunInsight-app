// features/chat_box/data/repositories_impl/chat_repository_impl.dart
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import 'package:runinsight/features/chat_box/domain/repositories/chat_repository.dart';
import '../services/gemini_service.dart';
import '../services/chat_storage_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiService _geminiService = GeminiService();
  final ChatStorageService _storageService = ChatStorageService();

  @override
  Future<List<ChatMessage>> sendMessage(String message) async {
    try {
      // Cargar mensajes existentes
      final existingMessages = await _storageService.loadMessages();
      print(
        '📥 Mensajes existentes en repositorio: ${existingMessages.length}',
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
        aiResponse = await _geminiService.generateResponse(
          'Primera vez: $message',
        );
      } else {
        // Para mensajes posteriores, incluir contexto de la conversación
        final recentMessages = existingMessages
            .skip(existingMessages.length > 4 ? existingMessages.length - 4 : 0)
            .map((m) => '${m.isUser ? "Usuario" : "Coach"}: ${m.content}')
            .join('\n');
        aiResponse = await _geminiService.generateResponse(
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
  Future<List<ChatMessage>> loadMessages() async {
    try {
      final messages = await _storageService.loadMessages();
      print('🔄 Repositorio cargó ${messages.length} mensajes');
      return messages;
    } catch (e) {
      print('❌ Error en repositorio al cargar: $e');
      return [];
    }
  }

  // Limpiar historial de chat
  Future<void> clearChat() async {
    await _storageService.clearMessages();
  }

  // Método de debug para verificar almacenamiento
  Future<void> debugStorage() async {
    await _storageService.debugStorage();
  }
}
