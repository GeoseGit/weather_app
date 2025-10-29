import 'package:flutter/material.dart';
import 'package:weather_app/widgets/head.dart';
import 'package:weather_app/widgets/main_temp.dart';
import 'package:weather_app/widgets/hourly_forecast.dart';
import 'package:weather_app/widgets/weekly_forecast.dart';
import 'package:weather_app/widgets/weather_details.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/models/service_api.dart';
import 'dart:convert';
import 'package:weather_app/widgets/preferences_service.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}


class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  
  String selectedCity = 'Краснодар';
  bool isLoading = true;
  String? error;
  
  WeatherData? currentWeather;

  @override
    void initState() {
      super.initState();
    _initializeApp();
    }

  Future<void> _initializeApp() async {
  selectedCity = await PreferencesService.getSavedCity();
  _loadWeatherData();
}

  Future<void> _loadWeatherData() async {
  setState(() {
    isLoading = true;
    error = null;
  });

  try {
     final rawData = await _weatherService.fetchWeather(selectedCity);
    
    // Конвертируем Map в JSON строку
    final jsonString = jsonEncode(rawData);
    
    // Используем существующий fromJson
    final data = WeatherData.fromJson(jsonString);
    
    setState(() {
      currentWeather = data;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      error = 'Не удалось загрузить данные: $e';
      isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error!)),
    );
  }
}

  void onCityChanged(String city) {
  PreferencesService.saveCity(city);
  setState(() {
    selectedCity = city;
  });
  _loadWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && currentWeather == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF60A5FA),
                Color(0xFF3B82F6),
                Color(0xFF9333EA),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Загрузка данных о погоде...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Показываем ошибку
    if (error != null && currentWeather == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF60A5FA),
                Color(0xFF3B82F6),
                Color(0xFF9333EA),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.white70),
                  SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadWeatherData,
                    child: Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF60A5FA), // blue-400
              Color(0xFF3B82F6), // blue-500
              Color(0xFF9333EA), // purple-600
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 448), // max-w-md
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        WeatherHeader(
                          city: selectedCity,
                          onCityChanged: onCityChanged,
                        ),
                        SizedBox(height: 24),
                          MainTemperature(weather: currentWeather!),
                        SizedBox(height: 24),
                        HourlyForecast(forecast: currentWeather!.hourlyForecast),
                        SizedBox(height: 24),
                        WeeklyForecast(forecast: currentWeather!.weeklyForecast),
                        SizedBox(height: 24),
                        WeatherDetails(details: currentWeather!.details),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}