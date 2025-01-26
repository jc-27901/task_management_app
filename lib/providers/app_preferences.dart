// lib/models/app_preferences.dart
import 'package:hive/hive.dart';

part 'app_preferences.g.dart';

@HiveType(typeId: 1)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark
}

@HiveType(typeId: 2)
enum TaskSortOrder {
  @HiveField(0)
  byDate,
  @HiveField(1)
  byPriority
}

@HiveType(typeId: 0)
class AppPreferences extends HiveObject {
  @HiveField(0)
  AppTheme theme;

  @HiveField(1)
  TaskSortOrder sortOrder;

  AppPreferences({
    this.theme = AppTheme.light,
    this.sortOrder = TaskSortOrder.byDate,
  });

  // Manual JSON serialization
  Map<String, String> toJson() {
    return {
      'theme': theme.toString().split('.').last,
      'sortOrder': sortOrder.toString().split('.').last,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      theme: AppTheme.values.firstWhere(
              (e) => e.toString().split('.').last == json['theme']
      ),
      sortOrder: TaskSortOrder.values.firstWhere(
              (e) => e.toString().split('.').last == json['sortOrder']
      ),
    );
  }

  // Utility method for copying with modifications
  AppPreferences copyWith({
    AppTheme? theme,
    TaskSortOrder? sortOrder,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}