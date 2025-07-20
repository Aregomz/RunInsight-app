// features/chat_box/presentation/widgets/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import 'package:runinsight/features/chat_box/domain/usecases/send_message.dart';
import 'package:runinsight/features/chat_box/data/repositories/chat_repository_impl.dart';
import 'package:runinsight/core/services/gemini_api_service.dart';
import '../bloc/chat_box_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_cleanup_notice.dart';
import 'package:runinsight/features/user/data/services/user_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = UserService.getUserId();
    if (userId == null) {
      return const Center(child: Text('Error: Usuario no autenticado'));
    }
    return BlocProvider(
      create: (context) {
        final repository = ChatRepositoryImpl(geminiApiService: GeminiApiService(), userId: userId);
        return ChatBloc(
          sendMessage: SendMessageUseCase(repository),
          repository: repository,
          userId: userId,
        );
      },
      child: const _ChatScreenView(),
    );
  }
}

class _ChatScreenView extends StatefulWidget {
  const _ChatScreenView();

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el BLoC para hacer scroll automático
    context.read<ChatBloc>().stream.listen((state) {
      if (state.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(ChatMessageSent(text));
    _controller.clear();

    // Hacer scroll automático después de enviar mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _navigateToPredictions() {
    Navigator.pushNamed(context, '/predictions');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<ChatBloc>().add(ClearChatHistory());
                        },
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        tooltip: 'Limpiar historial',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Notificación sutil de limpieza automática
              const ChatCleanupNotice(),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          itemCount: state.messages.length,
                          itemBuilder:
                              (_, index) =>
                                  ChatBubble(message: state.messages[index]),
                        ),
                        if (state is ChatLoading)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        if (state is ChatError)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: const EdgeInsets.all(16.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                state.error,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null, // Permite múltiples líneas
                      textInputAction:
                          TextInputAction.newline, // Enter para nueva línea
                      keyboardType: TextInputType.multiline, // Teclado multilínea
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        filled: true,
                        fillColor: Color(0xFF1C1C2E),
                        hintStyle: TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.orangeAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
