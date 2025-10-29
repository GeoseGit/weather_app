import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _cityKey = 'selected_city';

  static Future<String> getSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cityKey) ?? 'Краснодар';
    } catch (e) {
      return 'Краснодар';
    }
  }

  static Future<void> saveCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityKey, city);
    } catch (e) {
      print('Ошибка сохранения города: $e');
    }
  }
}