// features/chat_box/data/repositories_impl/chat_repository_impl.dart
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import 'package:runinsight/features/chat_box/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<ChatMessage>> sendMessage(String message) async {
    // Simulación de respuesta
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: "Estoy analizando tu progreso...",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
} 