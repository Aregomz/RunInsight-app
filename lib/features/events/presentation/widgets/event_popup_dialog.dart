import 'package:flutter/material.dart';
import 'dart:ui';

class EventPopupDialog extends StatefulWidget {
  final List<String> images;
  final VoidCallback onDismiss;

  const EventPopupDialog({
    super.key,
    required this.images,
    required this.onDismiss,
  });

  @override
  State<EventPopupDialog> createState() => _EventPopupDialogState();
}

class _EventPopupDialogState extends State<EventPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get images => widget.images;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack)),
    );
    _controller.forward();
    _pageController = PageController();
    // LOG: Imprimir imágenes al abrir el popup
    print('[EVENT POPUP] Lista de imágenes recibidas:');
    for (var i = 0; i < images.length; i++) {
      print('  [$i]: ${images[i]}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _close() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // LOG: Imprimir imagen actual cada vez que se construye
    print('[EVENT POPUP] Imagen actual (index $_currentPage): ${images[_currentPage]}');
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow exterior
              Container(
                width: size.width * 0.98 + 24,
                height: size.height * 0.85 + 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.25),
                      blurRadius: 48,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
              // Glassmorphism fondo
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: size.width * 0.98,
                    height: size.height * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.7),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Imagen de fondo difuminada + gradiente overlay (de la imagen actual)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        images[_currentPage],
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.22),
                        colorBlendMode: BlendMode.darken,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                      // Gradiente overlay sutil
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xCC0C0C27),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Carrusel de imágenes
              Center(
                child: SizedBox(
                  width: size.width * 0.85,
                  height: size.height * 0.60,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        // LOG: Imprimir imagen al cambiar de página
                        print('[EVENT POPUP] Imagen cambiada a (index $_currentPage): ${images[_currentPage]}');
                      });
                    },
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.95, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutExpo,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            color: Colors.black.withOpacity(0.10),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Indicadores de página (dots)
              if (images.length > 1)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: isActive ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.orangeAccent
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.orangeAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                ),
              // Botón de cerrar con animación
              Positioned(
                top: 16,
                right: 16,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTapDown: (_) => _controller.forward(from: 0.7),
                    onTapUp: (_) => _close(),
                    onTapCancel: () => _controller.reverse(),
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Puedes agregar aquí más widgets si el backend lo permite
            ],
          ),
        ),
      ),
    );
  }
} 