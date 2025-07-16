import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

class ChatStorageService {
  final int userId;
  ChatStorageService(this.userId);

  String get _chatKey => 'chat_messages_v2_ [93m$userId [0m';

  // Guardar mensajes en el almacenamiento local
  Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          messages.map((msg) => ChatMessageModel.fromEntity(msg).toJson()).toList();
      final jsonString = jsonEncode(messagesJson);
      final success = await prefs.setString(_chatKey, jsonString);
      print('💾 SAVE: \x1B[90m${messages.length}\x1B[0m messages, success: $success');
      if (success) {
        final savedMessages = await loadMessages();
        print('✅ VERIFICATION: \x1B[90m${savedMessages.length}\x1B[0m messages confirmed saved');
      }
    } catch (e) {
      print('❌ SAVE ERROR: $e');
      rethrow;
    }
  }

  // Cargar mensajes desde el almacenamiento local
  Future<List<ChatMessage>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_chatKey);
      print('🔍 LOAD: Key: $_chatKey, Raw data length: \x1B[90m${messagesString?.length ?? 0}\x1B[0m');
      if (messagesString == null || messagesString.isEmpty) {
        print('📭 NO SAVED MESSAGES');
        return [];
      }
      if (!messagesString.startsWith('[') || !messagesString.endsWith(']')) {
        print('❌ LOAD ERROR: Invalid JSON format');
        return [];
      }
      final messagesJson = jsonDecode(messagesString) as List;
      final messages = <ChatMessage>[];
      for (int i = 0; i < messagesJson.length; i++) {
        try {
          final model = ChatMessageModel.fromJson(messagesJson[i]);
          messages.add(model.toEntity());
        } catch (e) {
          print('⚠️ LOAD WARNING: Error parsing message $i: $e');
        }
      }
      print('📥 LOADED: \x1B[90m${messages.length}\x1B[0m messages');
      for (var msg in messages) {
        print('  - ${msg.isUser ? "USER" : "AI"}: ${msg.content.substring(0, msg.content.length > 30 ? 30 : msg.content.length)}...');
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
      print('➕ ADDING: ${message.content.substring(0, message.content.length > 30 ? 30 : message.content.length)}...');
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
        print('🔍 DEBUG: Raw data: ${messagesString.substring(0, messagesString.length > 200 ? 200 : messagesString.length)}...');
      }
    } catch (e) {
      print('❌ DEBUG ERROR: $e');
    }
  }
} 