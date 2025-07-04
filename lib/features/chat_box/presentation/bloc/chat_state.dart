part of 'chat_box_bloc.dart';

abstract class ChatState {
  final List<ChatMessage> messages;
  ChatState({this.messages = const []});
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded({required List<ChatMessage> messages}) : super(messages: messages);
} 