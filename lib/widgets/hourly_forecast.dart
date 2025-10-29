import 'package:flutter/material.dart';
import 'package:weather_app/models/hourly_weather.dart';
import 'glass_card.dart';

class HourlyForecast extends StatelessWidget {
  final List<HourlyWeather> forecast;

  const HourlyForecast({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              '3-часовой прогноз',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: forecast.map((hour) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  constraints: BoxConstraints(minWidth: 60),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          hour.time,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Icon(
                        hour.icon,
                        size: 24,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${hour.temp}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}