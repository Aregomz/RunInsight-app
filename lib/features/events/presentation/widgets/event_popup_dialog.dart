import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';

class EventPopupDialog extends StatefulWidget {
  final Event event;
  final VoidCallback onDismiss;

  const EventPopupDialog({
    super.key,
    required this.event,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: size.width * 0.98,
            height: size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              color: const Color(0xFF0C0C27),
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
            child: Stack(
              children: [
                // Imagen del evento (fondo)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(
                      widget.event.imgPath,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.25),
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
                  ),
                ),
                // Contenido principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con botón de cerrar
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: widget.onDismiss,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              tooltip: 'Cerrar',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Información del evento
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fecha del evento
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.event.isToday
                                  ? Colors.orangeAccent.withOpacity(0.18)
                                  : Colors.blueAccent.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.event.isToday
                                    ? Colors.orangeAccent
                                    : Colors.blueAccent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.event.isToday
                                  ? '¡HOY!'
                                  : '${widget.event.dateEvent.day.toString().padLeft(2, '0')}/${widget.event.dateEvent.month.toString().padLeft(2, '0')}/${widget.event.dateEvent.year}',
                              style: TextStyle(
                                color: widget.event.isToday
                                    ? Colors.orangeAccent
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Aquí podrías agregar más información del evento si el backend lo permite
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 