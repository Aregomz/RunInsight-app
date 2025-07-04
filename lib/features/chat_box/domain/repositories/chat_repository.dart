// features/chat_box/domain/repositories/chat_repository.dart
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> sendMessage(String message);
}