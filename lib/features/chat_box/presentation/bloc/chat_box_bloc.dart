// features/chat_box/presentation/bloc/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessage;

  ChatBloc({required this.sendMessage}) : super(ChatInitial()) {
    on<ChatMessageSent>(_onMessageSent);
  }

  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final messages = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    emit(ChatLoaded(messages: messages));

    final botResponse = await sendMessage(event.message);
    emit(ChatLoaded(messages: [...messages, ...botResponse.where((msg) => !msg.isUser)]));
  }
}