// lib/providers/preferences_provider.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/preference_data_source.dart';
import 'package:task_management_app/providers/app_preferences.dart';

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  final PreferencesDataSource _dataSource = PreferencesDataSource();

  PreferencesNotifier() : super(AppPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await _dataSource.getPreferences();
    state = preferences;
  }

  void updateTheme(AppTheme theme) {
    final updatedPreferences = state.copyWith(theme: theme);
    _dataSource.savePreferences(updatedPreferences);
    state = updatedPreferences;
  }

  void updateSortOrder(TaskSortOrder sortOrder) {
    final updatedPreferences = state.copyWith(sortOrder: sortOrder);
    _dataSource.savePreferences(updatedPreferences);
    state = updatedPreferences;
  }
}

// Create a provider for the PreferencesNotifier
final preferencesNotifierProvider = StateNotifierProvider<PreferencesNotifier, AppPreferences>((ref) {
  return PreferencesNotifier();
});