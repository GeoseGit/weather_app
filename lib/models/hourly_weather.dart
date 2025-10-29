import 'package:flutter/material.dart';
import 'dart:convert';


class HourlyWeather {
  final String time;
  final IconData icon;
  final int temp;

  HourlyWeather({
    required this.time,
    required this.icon,
    required this.temp,
  });
}

class ForecastItemDto {
  final String dtTxt;
  final double temp;
  final String iconCode;

  ForecastItemDto({
    required this.dtTxt,
    required this.temp,
    required this.iconCode,
  });

  factory ForecastItemDto.fromJson(Map<String, dynamic> json) {
    return ForecastItemDto(
      dtTxt: (json['dt_txt'] as String?) ?? '',
      temp: ((json['main']?['temp'] as num?) ?? 0).toDouble(),
      iconCode: ((json['weather'] as List?)?.first?['icon'] as String?) ?? '01d',
    );
  }

  static List<ForecastItemDto> listFromRootJson(String raw) {
    try {
      final root = jsonDecode(raw) as Map<String, dynamic>? ?? {};
      final list = root['list'] as List? ?? [];
      
      return list
          .map((e) => ForecastItemDto.fromJson(e as Map<String, dynamic>? ?? {}))
          .where((item) => item.dtTxt.isNotEmpty) // Фильтруем пустые
          .toList();
    } catch (e) {
      return [];
    }
  }
}

// Вынесенные функции вне класса
IconData mapIcon(String iconCode) {
  if (iconCode.startsWith('01')) return Icons.wb_sunny;
  if (iconCode.startsWith('02')) return Icons.wb_sunny;
  if (iconCode.startsWith('03')) return Icons.cloud;
  if (iconCode.startsWith('04')) return Icons.cloud;
  if (iconCode.startsWith('09')) return Icons.grain;
  if (iconCode.startsWith('10')) return Icons.water_drop;
  if (iconCode.startsWith('11')) return Icons.electric_bolt;
  if (iconCode.startsWith('13')) return Icons.ac_unit;
  if (iconCode.startsWith('50')) return Icons.foggy;
  return Icons.help_outline;
}

DateTime parseApiDateTime(String dtTxt) {
  final iso = dtTxt.replaceFirst(' ', 'T');
  return DateTime.parse(iso).toLocal();
}

String hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

HourlyWeather toDomain(ForecastItemDto dto, {bool markAsNow = false}) {
  final dt = parseApiDateTime(dto.dtTxt);
  return HourlyWeather(
    time: markAsNow ? 'Сейчас' : hhmm(dt),
    icon: mapIcon(dto.iconCode),
    temp: dto.temp.round(),
  );
}

List<HourlyWeather> buildHourlyWeather(String rawJson) {
  final dtos = ForecastItemDto.listFromRootJson(rawJson);

  // Ограничим количество элементов (например, 24 часа)
  final limitedDtos = dtos.take(8).toList();
  
  return [
    for (int i = 0; i < limitedDtos.length; i++)
      toDomain(limitedDtos[i], markAsNow: i == 0),
  ];
}