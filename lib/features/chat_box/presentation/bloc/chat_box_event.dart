// features/chat_box/presentation/bloc/chat_event.dart
part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String message;
  ChatMessageSent(this.message);
}