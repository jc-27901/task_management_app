// lib/data/preferences_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management_app/providers/app_preferences.dart';

class PreferencesDataSource {
  static const String _preferencesBoxName = 'app_preferences';
  static const String _preferencesKey = 'preferences';

  static final PreferencesDataSource _instance = PreferencesDataSource._internal();

  factory PreferencesDataSource() => _instance;

  PreferencesDataSource._internal();

  Future<void> initHive() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(AppThemeAdapter().typeId)) {
      Hive.registerAdapter(AppThemeAdapter());
    }
    if (!Hive.isAdapterRegistered(TaskSortOrderAdapter().typeId)) {
      Hive.registerAdapter(TaskSortOrderAdapter());
    }
    if (!Hive.isAdapterRegistered(AppPreferencesAdapter().typeId)) {
      Hive.registerAdapter(AppPreferencesAdapter());
    }
  }

  Future<void> savePreferences(AppPreferences preferences) async {
    final box = await Hive.openBox<AppPreferences>(_preferencesBoxName);
    await box.put(_preferencesKey, preferences);
    await box.close();
  }

  Future<AppPreferences> getPreferences() async {
    final box = await Hive.openBox<AppPreferences>(_preferencesBoxName);

    // Retrieve the preferences or return default if not exists
    final preferences = box.get(_preferencesKey);
    await box.close();

    return preferences ?? AppPreferences();
  }
}