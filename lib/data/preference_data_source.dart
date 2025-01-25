// lib/data/preferences_datasource.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/models/app_preferences.dart';

class PreferencesDataSource {
  static final PreferencesDataSource _instance = PreferencesDataSource._internal();

  factory PreferencesDataSource() => _instance;

  PreferencesDataSource._internal();

  Future<void> savePreferences(AppPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appPreferences', json.encode(preferences.toJson()));
  }

  Future<AppPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString('appPreferences');

    if (prefsJson != null) {
      final decodedJson = json.decode(prefsJson);
      return AppPreferences.fromJson(decodedJson);
    }

    return AppPreferences(); // Return default preferences
  }
}