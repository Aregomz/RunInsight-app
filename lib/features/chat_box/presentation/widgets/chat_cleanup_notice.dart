import 'package:flutter/material.dart';
import '../../data/services/chat_cleanup_service.dart';

class ChatCleanupNotice extends StatefulWidget {
  const ChatCleanupNotice({super.key});

  @override
  State<ChatCleanupNotice> createState() => _ChatCleanupNoticeState();
}

class _ChatCleanupNoticeState extends State<ChatCleanupNotice> {
  DateTime? _nextCleanupDate;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadNextCleanupDate();
  }

  Future<void> _loadNextCleanupDate() async {
    try {
      final nextDate = await ChatCleanupService.getNextCleanupDate();
      if (mounted) {
        setState(() {
          _nextCleanupDate = nextDate;
          _isVisible = true;
        });
      }
    } catch (e) {
      print('❌ Error al cargar fecha de limpieza: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _nextCleanupDate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final daysUntilCleanup = _nextCleanupDate!.difference(now).inDays;

    // Solo mostrar si faltan menos de 3 días para la limpieza
    if (daysUntilCleanup > 3) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.blue.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getCleanupMessage(daysUntilCleanup),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isVisible = false;
              });
            },
            icon: Icon(
              Icons.close,
              size: 16,
              color: Colors.blue.withOpacity(0.5),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _getCleanupMessage(int daysUntilCleanup) {
    if (daysUntilCleanup == 0) {
      return 'El historial se limpiará hoy para optimizar el rendimiento';
    } else if (daysUntilCleanup == 1) {
      return 'El historial se limpiará mañana para optimizar el rendimiento';
    } else {
      return 'El historial se limpiará en $daysUntilCleanup días para optimizar el rendimiento';
    }
  }
} 