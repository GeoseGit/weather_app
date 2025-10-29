import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_detail.dart';
import 'glass_card.dart';

class WeatherDetails extends StatelessWidget {
  final List<WeatherDetail> details;

  const WeatherDetails({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.7,
                child: Icon(
                  detail.icon,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Opacity(
                opacity: 0.7,
                child: Text(
                  detail.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                detail.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}