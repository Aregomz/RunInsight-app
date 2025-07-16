class RacePrediction {
  final double distance;
  final String unit;
  final String time;
  RacePrediction({required this.distance, required this.unit, required this.time});
}

class IaPredictionEntity {
  final String type; // Ej: 'ritmo', 'distancia', 'constancia'
  final double value; // Valor numérico de la predicción
  final String unit; // Ej: 'min/km', 'km', 'entrenamientos'
  final String description; // Explicación de la predicción
  final String icon; // Nombre del icono a mostrar
  final List<double>? chartData; // Datos para graficar tendencia
  final String? chartExplanation; // Explicación de la gráfica
  final List<RacePrediction>? racePredictions; // Predicciones de carrera

  IaPredictionEntity({
    required this.type,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    this.chartData,
    this.chartExplanation,
    this.racePredictions,
  });
} 