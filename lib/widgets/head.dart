import 'package:flutter/material.dart';
import 'package:weather_app/widgets/city_selector.dart';

class WeatherHeader extends StatelessWidget {
  final String city;
  final Function(String) onCityChanged;

  const WeatherHeader({
    Key? key,
    required this.city,
    required this.onCityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();
    int day = now.day;
    int month = now.month;
    
    // Список названий месяцев в родительном падеже
    List<String> monthNames = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    
    String monthName = monthNames[month - 1];


    return Column(
      children: [
        SizedBox(height: 16),
        Opacity(
          opacity: 0.9,
          child: Text(
            'Сегодня: $day $monthName',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 4),
        TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CitySelectorDialog(
                selectedCity: city,
                onCitySelected: (selectedCity) {
                  onCityChanged(selectedCity);
                  Navigator.pop(context);
                },
              ),
            );
          },
          icon: Icon(Icons.location_on, color: Colors.white, size: 20),
          label: Text(
            city,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}