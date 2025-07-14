import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/chat_message.dart';

class ChatStorageService {
  static const String _chatKey =
      'chat_messages_v2'; // Cambio de key para evitar conflictos

  // Guardar mensajes en el almacenamiento local
  Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          messages
              .map(
                (msg) => {
                  'id': msg.id,
                  'content': msg.content,
                  'isUser': msg.isUser,
                  'timestamp': msg.timestamp.toIso8601String(),
                },
              )
              .toList();

      final jsonString = jsonEncode(messagesJson);
      final success = await prefs.setString(_chatKey, jsonString);
      print('💾 SAVE: ${messages.length} messages, success: $success');

      // Verificar que se guardó correctamente
      if (success) {
        final savedMessages = await loadMessages();
        print(
          '✅ VERIFICATION: ${savedMessages.length} messages confirmed saved',
        );
      }
    } catch (e) {
      print('❌ SAVE ERROR: $e');
      rethrow; // Re-lanzar el error para que se maneje en el repositorio
    }
  }

  // Cargar mensajes desde el almacenamiento local
  Future<List<ChatMessage>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_chatKey);

      print(
        '🔍 LOAD: Key: $_chatKey, Raw data length: ${messagesString?.length ?? 0}',
      );

      if (messagesString == null || messagesString.isEmpty) {
        print('📭 NO SAVED MESSAGES');
        return [];
      }

      // Verificar que el JSON sea válido
      if (!messagesString.startsWith('[') || !messagesString.endsWith(']')) {
        print('❌ LOAD ERROR: Invalid JSON format');
        return [];
      }

      final messagesJson = jsonDecode(messagesString) as List;
      final messages = <ChatMessage>[];

      for (int i = 0; i < messagesJson.length; i++) {
        try {
          final json = messagesJson[i] as Map<String, dynamic>;
          final message = ChatMessage(
            id: json['id'] ?? '',
            content: json['content'] ?? '',
            isUser: json['isUser'] ?? false,
            timestamp: DateTime.parse(
              json['timestamp'] ?? DateTime.now().toIso8601String(),
            ),
          );
          messages.add(message);
        } catch (e) {
          print('⚠️ LOAD WARNING: Error parsing message $i: $e');
          // Continuar con el siguiente mensaje
        }
      }

      print('📥 LOADED: ${messages.length} messages');
      for (var msg in messages) {
        print(
          '  - ${msg.isUser ? "USER" : "AI"}: ${msg.content.substring(0, msg.content.length > 30 ? 30 : msg.content.length)}...',
        );
      }
      return messages;
    } catch (e) {
      print('❌ LOAD ERROR: $e');
      return [];
    }
  }

  // Limpiar todos los mensajes
  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_chatKey);
      print('🗑️ CLEARED: success: $success');
    } catch (e) {
      print('❌ CLEAR ERROR: $e');
    }
  }

  // Agregar un mensaje y guardar inmediatamente
  Future<void> addMessage(ChatMessage message) async {
    try {
      print(
        '➕ ADDING: ${message.content.substring(0, message.content.length > 30 ? 30 : message.content.length)}...',
      );
      final messages = await loadMessages();
      messages.add(message);
      await saveMessages(messages);
      print('✅ ADDED successfully');
    } catch (e) {
      print('❌ ADD ERROR: $e');
    }
  }

  // Método de debug para ver qué hay guardado
  Future<void> debugStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_chatKey);
      print('🔍 DEBUG: Key: $_chatKey');
      print('🔍 DEBUG: Raw data length: ${messagesString?.length ?? 0}');
      if (messagesString != null) {
        print(
          '🔍 DEBUG: Raw data: ${messagesString.substring(0, messagesString.length > 200 ? 200 : messagesString.length)}...',
        );
      }
    } catch (e) {
      print('❌ DEBUG ERROR: $e');
    }
  }
}
