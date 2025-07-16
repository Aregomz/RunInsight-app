import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/ia_coach/presentation/bloc/ia_coach_bloc.dart';
import 'package:runinsight/core/di/dependency_injection.dart';
import '../widgets/ia_coach_prediction_card.dart';

class IACoachPage extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final List<Map<String, dynamic>> lastTrainings;

  const IACoachPage({
    super.key,
    required this.userStats,
    required this.lastTrainings,
  });

  @override
  Widget build(BuildContext context) {
    print('IACoachPage: build called with userStats = $userStats, lastTrainings = $lastTrainings');
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Coach'),
        backgroundColor: const Color(0xFF0C0C27),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocProvider(
          create: (_) => DependencyInjection.getIaCoachBloc(),
          child: BlocBuilder<IaCoachBloc, IaCoachState>(
            builder: (context, state) {
              if (state is IaCoachInitial) {
                return Center(
                  child: _AnimatedFuturisticButton(
                    onPressed: () {
                      context.read<IaCoachBloc>().add(
                            IaCoachRequested(
                              userStats: userStats,
                              lastTrainings: lastTrainings,
                            ),
                          );
                    },
                  ),
                );
              } else if (state is IaCoachLoading) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Spacer(),
                    _FuturisticLoader(),
                    SizedBox(height: 24),
                    _BlinkingText(),
                    Spacer(),
                  ],
                );
              } else if (state is IaCoachLoaded) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: state.predictions.map((pred) => IACoachPredictionCard(prediction: pred)).toList(),
                );
              } else if (state is IaCoachError) {
                return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _FuturisticLoader extends StatefulWidget {
  const _FuturisticLoader();
  @override
  State<_FuturisticLoader> createState() => _FuturisticLoaderState();
}

class _FuturisticLoaderState extends State<_FuturisticLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = (_controller.value + i * 0.2) % 1.0;
              final offset = -10 * (1 - (t * 2 - 1).abs());
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Transform.translate(
                  offset: Offset(0, offset),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0FF0FC), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _AnimatedFuturisticButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedFuturisticButton({required this.onPressed});
  @override
  State<_AnimatedFuturisticButton> createState() => _AnimatedFuturisticButtonState();
}

class _AnimatedFuturisticButtonState extends State<_AnimatedFuturisticButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      constraints: const BoxConstraints(maxWidth: 400),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF0FF0FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(_pressed ? 0.55 : 0.35),
                blurRadius: _pressed ? 48 : 32,
                spreadRadius: _pressed ? 8 : 4,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.blueAccent.withOpacity(_pressed ? 0.28 : 0.18),
                blurRadius: _pressed ? 24 : 12,
                spreadRadius: _pressed ? 3 : 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const [
              Icon(Icons.memory, color: Colors.white, size: 28),
              SizedBox(width: 14),
              Flexible(
                child: Text(
                  'Obtener predicciones IA Coach',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.1,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlinkingText extends StatefulWidget {
  const _BlinkingText();
  @override
  State<_BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<_BlinkingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: const Text(
        'El coach está analizando tu perfil...',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          shadows: [
            Shadow(color: Colors.blueAccent, blurRadius: 12),
          ],
        ),
      ),
    );
  }
} 