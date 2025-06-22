// features/auth/presentation/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/core/widgets/gradient_button.dart';
import '../widgets/login_modal.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool showLoginModal = false;

  void _showLogin() {
    setState(() => showLoginModal = true);
  }

  void _hideLogin() {
    setState(() => showLoginModal = false);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ Color(0xFF050510), Color.fromARGB(255, 4, 4, 34)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: showLoginModal ? 0.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                    ),
                    children: [
                      const TextSpan(
                        text: 'Run',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(5, 12),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: 'Insight',
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [
                                Color(0xFFFF6B35), // Naranja
                                Color.fromARGB(255, 202, 81, 37), // Marrón oscuro
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0, 0, 200, 70), // Tamaño del área del texto
                            ),
                          shadows: const [
                            Shadow(
                              offset: Offset(5, 12),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                  const SizedBox(height: 8),
                  const Text(
                    'Entrena mas inteligente',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 80),
                  GradientButton(
                    onPressed: _showLogin,
                    text: 'Iniciar Sesión',
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 18),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => context.push('/register'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF4B2B), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Crear Cuenta',
                        style: TextStyle(
                            color: Color(0xFFFF4B2B),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          if (showLoginModal) LoginModal(onClose: _hideLogin),
        ],
      ),
    ),
    );
  }
}