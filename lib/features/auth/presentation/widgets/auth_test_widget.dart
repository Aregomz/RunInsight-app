import 'package:flutter/material.dart';
import '../../data/services/auth_init_service.dart';
import '../../../user/data/services/user_service.dart';

class AuthTestWidget extends StatefulWidget {
  const AuthTestWidget({super.key});

  @override
  State<AuthTestWidget> createState() => _AuthTestWidgetState();
}

class _AuthTestWidgetState extends State<AuthTestWidget> {
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

  Future<void> _testLogout() async {
    try {
      await AuthInitService.logout();
      await _loadSessionInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout completado - Prueba cerrar y abrir la app'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshSession() async {
    try {
      await _loadSessionInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información de sesión actualizada'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
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
                'Cargando información de autenticación...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final isLoggedIn = _sessionInfo['isLoggedIn'] ?? false;
    final userData = _sessionInfo['userData'] as Map<String, dynamic>?;
    final hasToken = _sessionInfo['hasToken'] ?? false;
    final hasUserData = _sessionInfo['hasUserData'] ?? false;
    final loginTimestamp = _sessionInfo['loginTimestamp'];
    final expiryTimestamp = _sessionInfo['expiryTimestamp'];

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
                  isLoggedIn ? Icons.security : Icons.security_outlined,
                  color: isLoggedIn ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Prueba de Persistencia de Auth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _refreshSession,
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Actualizar información',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Estado de Login', isLoggedIn ? 'Conectado' : 'Desconectado', 
                         isLoggedIn ? Colors.green : Colors.red),
            _buildInfoRow('Token Guardado', hasToken ? 'Sí' : 'No', 
                         hasToken ? Colors.green : Colors.red),
            _buildInfoRow('Datos de Usuario', hasUserData ? 'Sí' : 'No', 
                         hasUserData ? Colors.green : Colors.red),
            
            if (isLoggedIn && userData != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Usuario', userData['username'] ?? userData['email'] ?? 'N/A', Colors.blue),
              _buildInfoRow('ID', userData['id']?.toString() ?? 'N/A', Colors.blue),
            ],
            
            if (loginTimestamp != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Login', _formatTimestamp(loginTimestamp), Colors.orange),
            ],
            
            if (expiryTimestamp != null) ...[
              _buildInfoRow('Expiración', _formatTimestamp(expiryTimestamp), Colors.orange),
            ],
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLoggedIn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLoggedIn ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Text(
                isLoggedIn 
                    ? '✅ Sesión persistente activa - La app recordará tu login'
                    : '⚠️ Sin sesión persistente - Deberás hacer login cada vez',
                style: TextStyle(
                  color: isLoggedIn ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Probar Logout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Recargar la página actual para probar la redirección
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Recargar App'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Error: $e';
    }
  }
} 