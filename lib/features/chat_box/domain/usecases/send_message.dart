// features/chat_box/domain/usecases/send_message.dart
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<List<ChatMessage>> call(String message) async {
    return await repository.sendMessage(message);
  }
  
  Future<List<ChatMessage>> loadMessages({int? userId}) async {
    return await repository.loadMessages(userId: userId);
  }
  
  Future<void> clearChat({int? userId}) async {
    return await repository.clearChat(userId: userId);
  }
}