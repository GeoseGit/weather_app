import 'package:flutter/material.dart';
import 'hourly_weather.dart';
import 'daily_weather.dart';
import 'weather_detail.dart';
import 'dart:convert';

class ForecastItem {
  final DateTime dateTime;
  final double temp;
  final String description;

  ForecastItem({
    required this.dateTime,
    required this.temp,
    required this.description,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    // dt_txt приходит как "YYYY-MM-DD HH:mm:ss" — заменим пробел на 'T',
    // чтобы гарантированно корректно распарсить ISO8601.
    final raw = (json['dt_txt'] as String).trim();
    final dt = DateTime.parse(raw.replaceFirst(' ', 'T')); // => DateTime

    return ForecastItem(
      dateTime: dt,                                
      temp: (json['main']['temp'] as num).toDouble(),
      description: (json['weather'] as List).first['description'] as String,
    );
  }
}

Map<DateTime, ForecastItem> parseForecastMap(String jsonStr) {
  final root = jsonDecode(jsonStr) as Map<String, dynamic>;
  final List list = root['list'] as List;

  final items = list
      .map((e) => ForecastItem.fromJson(e as Map<String, dynamic>));

  // ключ — точное время (например, 2025-10-29 09:00:00)
  return {
    for (final f in items) f.dateTime: f,
  };
}

Map<String, dynamic> parseFirstForecast(String jsonStr) {
  final response = jsonDecode(jsonStr) as Map<String, dynamic>;
  final firstItem = (response['list'] as List).first as Map<String, dynamic>;
  
  // Безопасное извлечение данных с обработкой null
  final main = firstItem['main'] as Map<String, dynamic>? ?? {};
  final weatherList = firstItem['weather'] as List? ?? [];
  final weather = weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};
  final wind = firstItem['wind'] as Map<String, dynamic>? ?? {};
  
  return {
    'temp': (main['temp'] as num?)?.round() ?? 0,
    'description': (weather['description'] as String?) ?? 'Неизвестно',
    'humidity': main['humidity'] as int? ?? 0,
    'speed': (wind['speed'] as num?)?.toDouble() ?? 0.0,
    'visibility': firstItem['visibility'] as int? ?? 0,
    'pressure': main['pressure'] as int? ?? 0,
  };
}

DateTime parseApiDateTime(String dtTxt) {
  // "YYYY-MM-DD HH:mm:ss" → ISO
  final iso = dtTxt.replaceFirst(' ', 'T');
  return DateTime.parse(iso).toLocal(); // если API в UTC — приводим к локали
}

String hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

IconData mapIcon(String iconCode) {
  
  if (iconCode.startsWith('01')) return Icons.wb_sunny;         // ясно
  if (iconCode.startsWith('02')) return Icons.wb_sunny_outlined; // солнце с облачком (заменитель)
  if (iconCode.startsWith('03')) return Icons.cloud_queue;       // облачно
  if (iconCode.startsWith('04')) return Icons.cloud;             // пасмурно
  if (iconCode.startsWith('09')) return Icons.grain;             // морось/дождь
  if (iconCode.startsWith('10')) return Icons.umbrella;          // дождь
  if (iconCode.startsWith('11')) return Icons.flash_on;          // гроза
  if (iconCode.startsWith('13')) return Icons.ac_unit;           // снег
  if (iconCode.startsWith('50')) return Icons.blur_on;           // туман/дымка
  return Icons.help_outline;                                     // дефолт
}

List<HourlyWeather> buildHourlyWeather(String rawJson) {
  final dtos = ForecastItemDto.listFromRootJson(rawJson);

  
  return [
    for (int i = 0; i < 5; i++)
      toDomain(dtos[i], markAsNow: i == 0),
  ];
}

HourlyWeather toDomain(ForecastItemDto dto, {bool markAsNow = false}) {
  final dt = parseApiDateTime(dto.dtTxt);
  return HourlyWeather(
    time: markAsNow ? 'Сейчас' : hhmm(dt),
    icon: mapIcon(dto.iconCode),
    temp: dto.temp.round(),
  );
}


List<DailyWeather> getFiveDayForecast(String jsonStr) {
  final items = ForecastItemDto.listFromRootJson(jsonStr);
  final dailyForecasts = <DailyWeather>[];
  
  // Группируем прогнозы по дням
  final groupedByDay = <DateTime, List<ForecastItemDto>>{};
  
  for (final item in items) {
    final localDate = parseApiDateTime(item.dtTxt);
    final dayStart = DateTime(localDate.year, localDate.month, localDate.day);
    
    if (!groupedByDay.containsKey(dayStart)) {
      groupedByDay[dayStart] = [];
    }
    groupedByDay[dayStart]!.add(item);
  }
  

  final sortedDays = groupedByDay.keys.toList()..sort();
  
  for (final day in sortedDays.take(5)) {
    final dayForecasts = groupedByDay[day]!;
    
    final nightForecast = findForecastByHour(dayForecasts, 0);
    final dayForecast = findForecastByHour(dayForecasts, 15);
    
    if (nightForecast != null && dayForecast != null) {
      dailyForecasts.add(DailyWeather(
        day: _getDayName(day),
        icon: mapIcon(dayForecast.iconCode), // Используем вашу функцию mapIcon
        high: dayForecast.temp.round(),
        low: nightForecast.temp.round(),
      ));
    }
  }
  
  return dailyForecasts;
}

ForecastItemDto? findForecastByHour(List<ForecastItemDto> forecasts, int targetHour) {
  try {
    return forecasts.firstWhere((f) {
      final dt = parseApiDateTime(f.dtTxt);
      return dt.hour == targetHour;
    });
  } catch (e) {
    // Если точного времени нет, ищем ближайшее
    ForecastItemDto? closest;
    for (final forecast in forecasts) {
      final dt = parseApiDateTime(forecast.dtTxt);
      if (closest == null || 
          (dt.hour - targetHour).abs() < (parseApiDateTime(closest.dtTxt).hour - targetHour).abs()) {
        closest = forecast;
      }
    }
    return closest;
  }
}


String _getDayName(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(Duration(days: 1));
  final target = DateTime(date.year, date.month, date.day);
  
  if (target == today) return 'Сегодня';
  if (target == tomorrow) return 'Завтра';
  
  
  switch (date.weekday) {
    case 1: return 'Пн';
    case 2: return 'Вт';
    case 3: return 'Ср';
    case 4: return 'Чт';
    case 5: return 'Пт';
    case 6: return 'Сб';
    case 7: return 'Вс';
    default: return '';
  }
}

double _findExtremeTempForDay(Map<DateTime, ForecastItem> forecastMap, DateTime day, bool findMax) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = DateTime(day.year, day.month, day.day + 1);
  
  final dayTemps = forecastMap.entries
      .where((entry) => entry.key.isAfter(dayStart) && entry.key.isBefore(dayEnd))
      .map((entry) => entry.value.temp)
      .toList();
  
  if (dayTemps.isEmpty) return 0.0;
  
  return findMax ? 
      dayTemps.reduce((a, b) => a > b ? a : b) :
      dayTemps.reduce((a, b) => a < b ? a : b);
}



class WeatherData {
  final String location;
  final int temp;
  final String condition;
  final int high;
  final int low;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> weeklyForecast;
  final List<WeatherDetail> details;

  WeatherData({
    required this.location,
    required this.temp,
    required this.condition,
    required this.high,
    required this.low,
    required this.hourlyForecast,
    required this.weeklyForecast,
    required this.details,
  });

  factory WeatherData.fromJson(String jsonStr){
    Map<String, dynamic> json = jsonDecode(jsonStr);
    DateTime now = DateTime.now();
    final firstForecast = parseFirstForecast(jsonStr);
    final humidity = firstForecast['humidity'] as int;
    final speed = firstForecast['speed'] as double;
    final visibility = (firstForecast['visibility'] as int) / 1000;
    final pressure = firstForecast['pressure'] as int;
    return WeatherData(
      location:json['city']['name'],
      temp:parseFirstForecast(jsonStr)['temp'],
      condition:parseFirstForecast(jsonStr)['description'],
      high:_findExtremeTempForDay( parseForecastMap(jsonStr), now, true).round(),
      low:_findExtremeTempForDay( parseForecastMap(jsonStr), now, false).round(),
      hourlyForecast:buildHourlyWeather(jsonStr),
      weeklyForecast:getFiveDayForecast(jsonStr),
      details:[
        WeatherDetail(label: 'Влажность', value: '$humidity%', icon: Icons.water_drop),
        WeatherDetail(label: 'Ветер', value: '${speed.toStringAsFixed(1)} км/ч', icon: Icons.air),
        WeatherDetail(label: 'Видимость', value: '${visibility.toStringAsFixed(1)} км', icon: Icons.visibility),
        WeatherDetail(label: 'Давление', value: '$pressure мб', icon: Icons.speed),]
    );
  }
}