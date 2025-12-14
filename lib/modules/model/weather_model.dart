// lib/model/weather_model.dart
import 'dart:convert';

class Weather {
  final String description;
  final double temperature;

  Weather({required this.description, required this.temperature});

  factory Weather.fromJson(String str) {
    final jsonData = json.decode(str);
    return Weather(
      description: jsonData['weather'][0]['description'] ?? 'N/A',
      temperature: (jsonData['main']['temp']?.toDouble() ?? 0.0) - 273.15,
    );
  }

  factory Weather.fromDioResponse(Map<String, dynamic> jsonData) {
    return Weather(
      description: jsonData['weather'][0]['description'] ?? 'N/A',
      temperature: (jsonData['main']['temp']?.toDouble() ?? 0.0) - 273.15,
    );
  }

  @override
  String toString() {
    return 'Cuaca: $description, Suhu: ${temperature.toStringAsFixed(1)}°C';
  }
}
