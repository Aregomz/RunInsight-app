import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        isUser: json['isUser'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  ChatMessage toEntity() => ChatMessage(
        id: id,
        content: content,
        isUser: isUser,
        timestamp: timestamp,
      );

  static ChatMessageModel fromEntity(ChatMessage entity) => ChatMessageModel(
        id: entity.id,
        content: entity.content,
        isUser: entity.isUser,
        timestamp: entity.timestamp,
      );
} 