// lib/models/app_preferences.dart
enum AppTheme {
  light,
  dark
}

enum TaskSortOrder {
  byDate,
  byPriority
}

class AppPreferences {
  AppTheme theme;
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