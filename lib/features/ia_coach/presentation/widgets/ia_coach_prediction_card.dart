import 'package:flutter/material.dart';
import '../../domain/entities/ia_prediction_entity.dart';

class IACoachPredictionCard extends StatelessWidget {
  final IaPredictionEntity prediction;
  const IACoachPredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              const Color(0xFF6366F1).withOpacity(0.18),
              Colors.white.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    prediction.icon,
                    style: const TextStyle(fontSize: 40, shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 8)]),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      prediction.type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (prediction.value != 0.0)
                    Text(
                      '${prediction.value} ${prediction.unit}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                prediction.description,
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
              ),
              if (prediction.chartData != null && prediction.chartData!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniChart(data: prediction.chartData!),
                      if (prediction.chartExplanation != null && prediction.chartExplanation!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            prediction.chartExplanation!,
                            style: const TextStyle(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              if (prediction.racePredictions != null && prediction.racePredictions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Predicción de tiempos estimados en carreras:',
                        style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      ...prediction.racePredictions!.map((race) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '${race.distance.toStringAsFixed(0)}${race.unit}: ${race.time}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<double> data;
  const _MiniChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = (max - min == 0) ? 1 : max - min;
    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((v) {
          final percent = (v - min) / range;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 16 + percent * 16,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 