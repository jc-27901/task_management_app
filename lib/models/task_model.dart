// lib/models/task_model.dart

enum TaskStatus { pending, completed }

enum TaskPriority { high, medium, low }

enum TaskType {
  codeReview('Code Review'),
  meeting('Meeting'),
  development('Development'),
  others('Others');

  final String name;
  const TaskType(this.name);
}

class Task {
  String? id;
  String title;
  String? description;
  DateTime createdAt;
  DateTime? completedAt;
  TaskStatus status;
  DateTime? dueDate;
  TaskPriority? taskPriority;
  TaskType taskType;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.taskPriority,
    this.taskType = TaskType.others
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
      'taskPriority': taskPriority.toString().split('.').last,
      'taskType' : taskType.toString().split('.').last
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
      status: TaskStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      taskPriority: TaskPriority.values.firstWhere(
          (e) => e.toString().split('.').last == json['taskPriority']),
      taskType: TaskType.values.firstWhere(
              (e) => e.toString().split('.').last == json['taskType']),
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
    TaskPriority? taskPriority,
  }) {
    return Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        status: status ?? this.status,
        dueDate: dueDate ?? this.dueDate,
        taskPriority: taskPriority ?? this.taskPriority);
  }
}
