part of 'chat_box_bloc.dart';

abstract class ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String message;
  ChatMessageSent(this.message);
} 