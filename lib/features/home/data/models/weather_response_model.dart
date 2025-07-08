class WeatherResponseModel {
  final List<WeatherDataModel> data;

  WeatherResponseModel({required this.data});

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    return WeatherResponseModel(
      data: (json['data'] as List)
          .map((item) => WeatherDataModel.fromJson(item))
          .toList(),
    );
  }
}

class WeatherDataModel {
  final WeatherInfoModel weather;
  final double temp;
  final int? pop;
  final double? precip;

  WeatherDataModel({
    required this.weather,
    required this.temp,
    this.pop,
    this.precip,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      weather: WeatherInfoModel.fromJson(json['weather']),
      temp: (json['temp'] as num).toDouble(),
      pop: json['pop'] is int ? json['pop'] : (json['pop'] as num?)?.toInt(),
      precip: json['precip'] != null ? (json['precip'] as num).toDouble() : null,
    );
  }
}

class WeatherInfoModel {
  final int code;
  final String description;

  WeatherInfoModel({required this.code, required this.description});

  factory WeatherInfoModel.fromJson(Map<String, dynamic> json) {
    return WeatherInfoModel(
      code: json['code'],
      description: json['description'],
    );
  }
} 