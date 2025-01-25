// lib/models/task_model.dart
import 'dart:convert';

enum TaskStatus {
  pending,
  completed
}

class Task {
  String? id;
  String title;
  String? description;
  DateTime createdAt;
  DateTime? completedAt;
  TaskStatus status;
  DateTime? dueDate;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.status = TaskStatus.pending,
    this.dueDate,
  });

  // Manual JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      status: TaskStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status']
      ),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
    );
  }

  // Utility method for copying with modifications
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

// lib/models/app_preferences.dart
enum AppTheme {
  light,
  dark
}

enum TaskSortOrder {
  byDate,
  byPriority,
  byCreationDate
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