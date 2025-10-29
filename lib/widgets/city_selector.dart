import 'package:flutter/material.dart';
import 'package:weather_app/models/cities.dart';

class CitySelectorDialog extends StatefulWidget {
  final String selectedCity;
  final Function(String) onCitySelected;

  const CitySelectorDialog({
    Key? key,
    required this.selectedCity,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  State<CitySelectorDialog> createState() => _CitySelectorDialogState();
}

class _CitySelectorDialogState extends State<CitySelectorDialog> {
  String searchQuery = '';

  // Фильтрация городов по поисковому запросу
  List<String> get filteredCities {
  if (searchQuery.isEmpty) {
    return russianCities.values.toList();
  }

  final query = searchQuery.toLowerCase();

  return russianCities.values.where((cityValue) {
    final cityLower = cityValue.toLowerCase();

    // Разбиваем ключ на слова (по пробелам и дефисам)
    final words = cityLower.split(RegExp(r'[\s-]+'));

    // Проверяем начало каждого слова
    return words.any((word) => word.startsWith(query));
  }).toList();
}

  void _onCitySelected(String city) {
    widget.onCitySelected(city);
    // Очищаем поиск при закрытии (опционально)
    setState(() {
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите город',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Введите название города или выберите из списка',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Поисковая строка
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Поиск города...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            SizedBox(height: 16),
            Divider(height: 1),

            // Список городов или сообщение "Город не найден"
            Expanded(
              child: filteredCities.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected = city == widget.selectedCity;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _onCitySelected(city),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      city,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Город не найден',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                'Попробуйте изменить запрос',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
