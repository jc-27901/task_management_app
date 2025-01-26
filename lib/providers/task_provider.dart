// lib/providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/task_data_source.dart';
import '../models/task_model.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskDataSource _dataSource = TaskDataSource();

  TaskNotifier() : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final List<Task> tasks = await _dataSource.getTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _dataSource.insertTask(task);
      final updatedTasks = [...state.value!, task];
      state = AsyncValue.data(updatedTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _dataSource.updateTask(task);
      final updatedTasks =
          state.value!.map((t) => t.id == task.id ? task : t).toList();
      state = AsyncValue.data(updatedTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
      final updatedTasks = state.value!.where((t) => t.id != taskId).toList();
      state = AsyncValue.data(updatedTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Create a provider for the TaskNotifier
final StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>
    taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier();
});
