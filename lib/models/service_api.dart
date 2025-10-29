import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/api.dart';
import 'cities.dart';


String? findKeyByValue(Map<String, String> map, String value) {
  for (var entry in map.entries) {
    if (entry.value == value) {
      return entry.key;
    }
  }
  return null;
}


class WeatherService{
  final String apiKey = apiWeather;
  final String baseURL = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> fetchWeather(String ity) async {
    var city = findKeyByValue(russianCities, ity);
    final url = '$baseURL/forecast?q=$city&lang=ru&appid=$apiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else if (response.statusCode == 401) {
      throw Exception("Неверный API ключ. Проверьте файл api.dart");
    }
    else if (response.statusCode == 404) {
      throw Exception("Город '$city' не найден");
    }
    else{
      throw Exception("Ошибка API: ${response.statusCode}");
    }
  }
}