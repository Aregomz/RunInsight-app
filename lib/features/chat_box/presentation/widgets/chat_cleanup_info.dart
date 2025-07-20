import 'package:flutter/material.dart';
import '../../data/services/chat_cleanup_service.dart';

class ChatCleanupInfo extends StatefulWidget {
  const ChatCleanupInfo({super.key});

  @override
  State<ChatCleanupInfo> createState() => _ChatCleanupInfoState();
}

class _ChatCleanupInfoState extends State<ChatCleanupInfo> {
  bool _isCleanupEnabled = true;
  DateTime? _nextCleanupDate;

  @override
  void initState() {
    super.initState();
    _loadCleanupSettings();
  }

  Future<void> _loadCleanupSettings() async {
    try {
      final enabled = await ChatCleanupService.isCleanupEnabled();
      final nextDate = await ChatCleanupService.getNextCleanupDate();
      
      if (mounted) {
        setState(() {
          _isCleanupEnabled = enabled;
          _nextCleanupDate = nextDate;
        });
      }
    } catch (e) {
      print('❌ Error al cargar configuración de limpieza: $e');
    }
  }

  Future<void> _toggleCleanup(bool value) async {
    try {
      await ChatCleanupService.setCleanupEnabled(value);
      setState(() {
        _isCleanupEnabled = value;
      });
    } catch (e) {
      print('❌ Error al cambiar configuración de limpieza: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C2E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_delete_outlined,
                  color: Colors.blue.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Limpieza Automática',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'El historial del chat se limpia automáticamente cada domingo para optimizar el rendimiento y ahorrar espacio.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCleanupEnabled ? 'Habilitado' : 'Deshabilitado',
                        style: TextStyle(
                          color: _isCleanupEnabled ? Colors.green : Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isCleanupEnabled,
                  onChanged: _toggleCleanup,
                  activeColor: Colors.blue,
                ),
              ],
            ),
            if (_nextCleanupDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próxima limpieza:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatNextCleanupDate(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNextCleanupDate() {
    if (_nextCleanupDate == null) return 'No programada';
    
    final now = DateTime.now();
    final daysUntilCleanup = _nextCleanupDate!.difference(now).inDays;
    
    if (daysUntilCleanup == 0) {
      return 'Hoy';
    } else if (daysUntilCleanup == 1) {
      return 'Mañana';
    } else {
      return 'En $daysUntilCleanup días';
    }
  }
} 