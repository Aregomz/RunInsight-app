// features/chat_box/presentation/widgets/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:runinsight/features/chat_box/domain/entities/chat_message.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      // Simular respuesta de IA
      _messages.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Procesando...',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();

    // Aquí se llamaría al modelo o API real en el futuro
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
          content: 'Esta es una respuesta generada automáticamente.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  void _navigateToPredictions() {
    Navigator.pushNamed(context, '/predictions');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton.icon(
              onPressed: _navigateToPredictions,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Ver predicciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) => ChatBubble(message: _messages[index]),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    filled: true,
                    fillColor: Color(0xFF1C1C2E),
                    hintStyle: TextStyle(color: Colors.white60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.orangeAccent),
              ),
            ],
          )
        ],
      ),
    );
  }
}
