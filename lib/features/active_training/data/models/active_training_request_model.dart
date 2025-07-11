class ActiveTrainingRequestModel {
  final int timeMinutes;
  final double distanceKm;
  final double rhythm;
  final String date;
  final double altitude;
  final String? notes;
  final String trainingType;
  final String terrainType;
  final String weather;

  ActiveTrainingRequestModel({
    required this.timeMinutes,
    required this.distanceKm,
    required this.rhythm,
    required this.date,
    required this.altitude,
    this.notes,
    required this.trainingType,
    required this.terrainType,
    required this.weather,
  });

  // Mapear descripciones de clima a tipos esperados por el backend
  String _mapWeatherToBackendType(String weatherDescription) {
    final description = weatherDescription.toLowerCase();
    
    // Mapear descripciones a tipos de clima válidos para el backend
    // Valores exactos esperados por el backend:
    // 1. Soleado, 2. Nublado, 3. Lluvioso, 4. Ventoso, 5. Nevado, 6. Húmedo, 7. Seco, 8. Tormenta
    
    if (description.contains('tormenta') || description.contains('storm')) {
      return 'Tormenta';
    }
    if (description.contains('lluvia') || description.contains('rain') || description.contains('llovizna') || description.contains('drizzle')) {
      return 'Lluvioso';
    }
    if (description.contains('nieve') || description.contains('snow') || description.contains('nevado')) {
      return 'Nevado';
    }
    if (description.contains('niebla') || description.contains('fog') || description.contains('mist') || description.contains('húmedo')) {
      return 'Húmedo';
    }
    if (description.contains('nublado') || description.contains('cloudy') || description.contains('parcialmente')) {
      return 'Nublado';
    }
    if (description.contains('perfecto') || description.contains('clear') || description.contains('despejado') || description.contains('seco')) {
      return 'Soleado';
    }
    if (description.contains('viento') || description.contains('wind') || description.contains('ventoso')) {
      return 'Ventoso';
    }
    
    // Por defecto, usar Soleado si no se reconoce
    return 'Soleado';
  }

  Map<String, dynamic> toJson() => {
    'time_minutes': timeMinutes,
    'distance_km': distanceKm,
    'rhythm': rhythm,
    'date': date,
    'altitude': altitude,
    if (notes != null) 'notes': notes,
    'trainingType': trainingType,
    'terrainType': terrainType,
    'weather': _mapWeatherToBackendType(weather),
  };
} 