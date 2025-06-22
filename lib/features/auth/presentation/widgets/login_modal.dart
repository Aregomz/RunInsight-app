// features/auth/presentation/widgets/login_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/core/widgets/gradient_button.dart';
import '../bloc/auth_bloc.dart';

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
                            if (state is AuthSuccess) widget.onClose();
                            if (state is AuthFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
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
                                    controller: emailCtrl, hintText: 'Email'),
                                const SizedBox(height: 16),
                                _buildTextField(
                                    controller: passCtrl,
                                    hintText: 'Contraseña',
                                    obscureText: true),
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
      bool obscureText = false}) {
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
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
