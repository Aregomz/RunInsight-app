part of 'chat_box_bloc.dart';

abstract class ChatState {
  final List<ChatMessage> messages;
  ChatState({this.messages = const []});
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  ChatLoading({required List<ChatMessage> messages})
    : super(messages: messages);
}

class ChatLoaded extends ChatState {
  ChatLoaded({required List<ChatMessage> messages}) : super(messages: messages);
}

class ChatError extends ChatState {
  final String error;
  ChatError({required List<ChatMessage> messages, required this.error})
    : super(messages: messages);
}
