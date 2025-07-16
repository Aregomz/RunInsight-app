// features/chat_box/presentation/bloc/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message.dart';
import '../../data/repositories/chat_repository_impl.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessage;
  final ChatRepositoryImpl repository;
  final int userId;

  ChatBloc({required this.sendMessage, required this.repository, required this.userId})
    : super(ChatInitial()) {
    on<ChatMessageSent>(_onMessageSent);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ClearChatHistory>(_onClearChatHistory);

    // Cargar historial al inicializar inmediatamente
    print('🚀 BLoC inicializado, cargando historial...');
    // Usar un pequeño delay para asegurar que se ejecute después de la inicialización
    Future.delayed(const Duration(milliseconds: 100), () {
      add(LoadChatHistory());
    });
  }

  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    try {
      print('📤 Enviando mensaje: ${event.message}');

      // Cargar mensajes existentes primero
      final existingMessages = await repository.loadMessages(userId: userId);
      print('📥 Mensajes existentes: ${existingMessages.length}');

      // Mostrar estado de carga con mensajes existentes
      emit(ChatLoading(messages: existingMessages));

      // Obtener respuesta de la IA (esto ya guarda los mensajes en el repositorio)
      final newMessages = await sendMessage(event.message);
      print(
        '✅ Respuesta de IA recibida, ${newMessages.length} nuevos mensajes',
      );

      // Cargar todos los mensajes actualizados desde el almacenamiento
      final allMessages = await repository.loadMessages(userId: userId);
      print('📥 BLoC actualizado con ${allMessages.length} mensajes total');

      emit(ChatLoaded(messages: allMessages));
    } catch (e) {
      print('❌ Error en BLoC: $e');
      // En caso de error, mantener los mensajes existentes
      final existingMessages = await repository.loadMessages(userId: userId);
      emit(ChatLoaded(messages: existingMessages));
    }
  }

  void _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔄 BLoC: Cargando historial...');

      // Intentar cargar mensajes múltiples veces si es necesario
      List<ChatMessage> messages = [];
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts) {
        try {
          messages = await repository.loadMessages(userId: userId);
          print(
            '✅ BLoC: Historial cargado con ${messages.length} mensajes (intento ${attempts + 1})',
          );
          break;
        } catch (e) {
          attempts++;
          print('⚠️ BLoC: Intento ${attempts} falló: $e');
          if (attempts >= maxAttempts) {
            print('❌ BLoC: Todos los intentos fallaron');
            throw e;
          }
          await Future.delayed(Duration(milliseconds: 100 * attempts));
        }
      }

      emit(ChatLoaded(messages: messages));
    } catch (e) {
      print('❌ BLoC: Error al cargar historial: $e');
      emit(ChatLoaded(messages: []));
    }
  }

  void _onClearChatHistory(
    ClearChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await repository.clearChat(userId: userId);
      emit(ChatLoaded(messages: []));
    } catch (e) {
      emit(
        ChatError(
          messages: state.messages,
          error: 'Error al limpiar el historial: ${e.toString()}',
        ),
      );
    }
  }
}
