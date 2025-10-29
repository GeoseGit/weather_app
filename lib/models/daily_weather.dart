import 'package:flutter/material.dart';

class DailyWeather {
  final String day;
  final IconData icon;
  final int high;
  final int low;

  DailyWeather({
    required this.day,
    required this.icon,
    required this.high,
    required this.low,
  });
}