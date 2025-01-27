// lib/providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/task_data_source.dart';
import '../models/task_model.dart';

// Class to hold both tasks and selected task state
class TaskState {
  final AsyncValue<List<Task>> tasks;
  final Task? selectedTask;

  const TaskState({
    required this.tasks,
    this.selectedTask,
  });

  // Helper method to create new state
  TaskState copyWith({
    AsyncValue<List<Task>>? tasks,
    Task? selectedTask,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskDataSource _dataSource = TaskDataSource();

  TaskNotifier()
      : super(const TaskState(tasks: AsyncValue.loading())) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final List<Task> tasks = await _dataSource.getTasks();
      state = TaskState(tasks: AsyncValue.data(tasks));
    } catch (error, stackTrace) {
      state = TaskState(tasks: AsyncValue.error(error, stackTrace));
    }
  }

  // Method to select a task
  void selectTask(Task? task) {
    state = state.copyWith(selectedTask: task);
  }

  Future<void> addTask(Task task) async {
    try {
      await _dataSource.insertTask(task);
      final currentTasks = state.tasks.value ?? [];
      final updatedTasks = [...currentTasks, task];
      state = state.copyWith(tasks: AsyncValue.data(updatedTasks));
    } catch (error, stackTrace) {
      state = state.copyWith(tasks: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _dataSource.updateTask(task);
      final currentTasks = state.tasks.value ?? [];
      final updatedTasks = currentTasks.map((t) => t.id == task.id ? task : t).toList();

      // Update selected task if it was the one that was modified
      final updatedSelectedTask = state.selectedTask?.id == task.id ? task : state.selectedTask;

      state = state.copyWith(
        tasks: AsyncValue.data(updatedTasks),
        selectedTask: updatedSelectedTask,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(tasks: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
      final currentTasks = state.tasks.value ?? [];
      final updatedTasks = currentTasks.where((t) => t.id != taskId).toList();

      // Clear selected task if it was the one that was deleted
      final updatedSelectedTask = state.selectedTask?.id == taskId ? null : state.selectedTask;

      state = state.copyWith(
        tasks: AsyncValue.data(updatedTasks),
        selectedTask: updatedSelectedTask,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(tasks: AsyncValue.error(error, stackTrace));
    }
  }
}

// Updated provider definition
final taskNotifierProvider =
StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier();
});