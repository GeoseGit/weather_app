import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_data.dart';

class MainTemperature extends StatelessWidget {
  final WeatherData weather;

  const MainTemperature({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Opacity(
            opacity: 0.9,
            child: Icon(
              Icons.cloud_outlined,
              size: 96,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '${weather.temp}°',
            style: TextStyle(
              fontSize: 72,
              color: Colors.white,
              letterSpacing: -2,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          SizedBox(height: 8),
          Opacity(
            opacity: 0.9,
            child: Text(
              weather.condition,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12),
          Opacity(
            opacity: 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Макс: ${weather.high}°',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 16),
                Text('•', style: TextStyle(color: Colors.white)),
                SizedBox(width: 16),
                Text(
                  'Мин: ${weather.low}°',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
