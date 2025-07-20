import 'package:flutter/material.dart';
import '../../data/services/auth_init_service.dart';

class SessionStatusWidget extends StatefulWidget {
  const SessionStatusWidget({super.key});

  @override
  State<SessionStatusWidget> createState() => _SessionStatusWidgetState();
}

class _SessionStatusWidgetState extends State<SessionStatusWidget> {
  Map<String, dynamic> _sessionInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    try {
      final sessionInfo = await AuthInitService.getSessionInfo();
      if (mounted) {
        setState(() {
          _sessionInfo = sessionInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AuthInitService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar información de sesión
        await _loadSessionInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        color: Color(0xFF1C1C2E),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text(
                'Cargando sesión...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final isLoggedIn = _sessionInfo['isLoggedIn'] ?? false;
    final userData = _sessionInfo['userData'] as Map<String, dynamic>?;
    final loginTimestamp = _sessionInfo['loginTimestamp'];

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
                  isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined,
                  color: isLoggedIn ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? 'Sesión Activa' : 'Sin Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLoggedIn && userData != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Usuario: ${userData['username'] ?? userData['email'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isLoggedIn)
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'Cerrar sesión',
                  ),
              ],
            ),
            if (isLoggedIn && loginTimestamp != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Conectado desde: ${_formatTimestamp(loginTimestamp)}',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLoggedIn ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLoggedIn ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Text(
                isLoggedIn ? 'Persistente' : 'No persistente',
                style: TextStyle(
                  color: isLoggedIn ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Ahora mismo';
      }
    } catch (e) {
      return 'Desconocido';
    }
  }
} 