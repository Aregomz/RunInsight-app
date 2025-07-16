// features/auth/presentation/widgets/login_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginModal extends StatefulWidget {
  final VoidCallback onClose;

  const LoginModal({super.key, required this.onClose});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _obscurePassword = true; // Add this line to track password visibility

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: widget.onClose,
        child: Stack(
          children: [
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    bottom: -300 * (1 - _animation.value),
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {}, // Evita que se cierre el modal al tocar dentro
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C2E).withOpacity(0.9),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              widget.onClose();
                              context.go('/home');
                            }
                            if (state is AuthFailure) {
                              // Determinar el color del SnackBar según el tipo de error
                              Color snackBarColor;
                              IconData icon;
                              String title;
                              
                              if (state.message.contains('Contraseña incorrecta')) {
                                snackBarColor = Colors.orange;
                                icon = Icons.lock_outline;
                                title = 'Error de Contraseña';
                              } else if (state.message.contains('Usuario no encontrado')) {
                                snackBarColor = Colors.blue;
                                icon = Icons.person_off;
                                title = 'Usuario No Encontrado';
                              } else if (state.message.contains('Credenciales incorrectas')) {
                                snackBarColor = Colors.orange;
                                icon = Icons.warning;
                                title = 'Credenciales Inválidas';
                              } else if (state.message.contains('Error del servidor')) {
                                snackBarColor = Colors.red;
                                icon = Icons.error;
                                title = 'Error del Servidor';
                              } else if (state.message.contains('Error de conexión')) {
                                snackBarColor = Colors.blue;
                                icon = Icons.wifi_off;
                                title = 'Error de Conexión';
                              } else {
                                snackBarColor = Colors.red;
                                icon = Icons.error_outline;
                                title = 'Error';
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(icon, color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          state.message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  backgroundColor: snackBarColor,
                                  duration: const Duration(seconds: 5),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  elevation: 8,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Iniciar Sesión',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 24),
                                _buildTextField(
                                    controller: emailCtrl, hintText: 'Email o Usuario'),
                                const SizedBox(height: 16),
                                _buildTextField(
                                    controller: passCtrl,
                                    hintText: 'Contraseña',
                                    obscureText: _obscurePassword,
                                    isPassword: true), // Add isPassword parameter
                                const SizedBox(height: 30),
                                GradientButton(
                                  width: double.infinity,
                                  onPressed: state is AuthLoading
                                      ? () {}
                                      : () => context.read<AuthBloc>().add(
                                            LoginRequested(
                                              email: emailCtrl.text,
                                              password: passCtrl.text,
                                            ),
                                          ),
                                  text: state is AuthLoading
                                      ? 'Cargando...'
                                      : 'Entrar',
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: widget.onClose,
                                  child: const Text('Volver',
                                      style: TextStyle(color: Colors.white70)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      bool obscureText = false,
      bool isPassword = false}) { // Add isPassword parameter
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2A3D),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.white54,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ) : null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
