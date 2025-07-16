import '../../domain/entities/ia_prediction_entity.dart';

class IaPredictionModel extends IaPredictionEntity {
  IaPredictionModel({
    required String type,
    required double value,
    required String unit,
    required String description,
    required String icon,
    List<double>? chartData,
    String? chartExplanation,
    List<RacePrediction>? racePredictions,
  }) : super(
          type: type,
          value: value,
          unit: unit,
          description: description,
          icon: icon,
          chartData: chartData,
          chartExplanation: chartExplanation,
          racePredictions: racePredictions,
        );

  factory IaPredictionModel.fromJson(Map<String, dynamic> json) {
    return IaPredictionModel(
      type: json['type'] ?? '',
      value: (json['value'] is num)
          ? (json['value'] as num).toDouble()
          : 0.0,
      unit: json['unit']?.toString() ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      chartData: (json['chartData'] as List<dynamic>?)
          ?.where((e) => e != null)
          .map((e) => (e as num).toDouble())
          .toList(),
      chartExplanation: json['chartExplanation'],
      racePredictions: (json['racePredictions'] as List<dynamic>?)?.map((e) => RacePredictionModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'unit': unit,
        'description': description,
        'icon': icon,
        'chartData': chartData,
        'chartExplanation': chartExplanation,
        'racePredictions': racePredictions?.map((e) => (e as RacePredictionModel).toJson()).toList(),
      };
}

class RacePredictionModel extends RacePrediction {
  RacePredictionModel({required double distance, required String unit, required String time})
      : super(distance: distance, unit: unit, time: time);

  factory RacePredictionModel.fromJson(Map<String, dynamic> json) {
    return RacePredictionModel(
      distance: (json['distance'] is num) ? (json['distance'] as num).toDouble() : 0.0,
      unit: json['unit']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'unit': unit,
        'time': time,
      };
} 