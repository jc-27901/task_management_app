// lib/views/task_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/models/app_preferences.dart';
import 'package:task_management_app/providers/preference_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Task>> tasksAsync = ref.watch(taskNotifierProvider);
    final AppPreferences preferences = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(preferences.theme == AppTheme.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              ref.read(preferencesNotifierProvider.notifier).updateTheme(
                  preferences.theme == AppTheme.light
                      ? AppTheme.dark
                      : AppTheme.light);
            },
          ),
          // Sort Order Dropdown
          PopupMenuButton<TaskSortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (TaskSortOrder sortOrder) {
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateSortOrder(sortOrder);
            },
            itemBuilder: (BuildContext context) =>
                TaskSortOrder.values.map((TaskSortOrder sortOrder) {
              return PopupMenuItem<TaskSortOrder>(
                value: sortOrder,
                child: Text(sortOrder.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          // Apply sorting based on preferences
          final List<Task> sortedTasks =
              _sortTasks(tasks, preferences.sortOrder);
          return ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TaskListItem(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Sorting method for tasks
  List<Task> _sortTasks(List<Task> tasks, TaskSortOrder sortOrder) {
    switch (sortOrder) {
      case TaskSortOrder.byDate:
        return List.from(tasks)
          ..sort((a, b) =>
              (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt));
      case TaskSortOrder.byPriority:
        // Assuming we might add priority later
        return tasks;
    }
  }

  // Dialog to add new task
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController titleC = TextEditingController();
    final TextEditingController descriptionC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                ),
              ),
              TextField(
                controller: descriptionC,
                decoration: const InputDecoration(
                  hintText: 'Description (Optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.isNotEmpty) {
                  final Task newTask = Task(
                    id: const Uuid().v4(), // Generate unique ID
                    title: titleC.text,
                    description:
                        descriptionC.text.isNotEmpty ? descriptionC.text : null,
                    createdAt: DateTime.now(),
                    status: TaskStatus.pending,
                  );

                  ref.read(taskNotifierProvider.notifier).addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TaskListItem extends ConsumerWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        task.title,
        style: task.status == TaskStatus.completed
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: task.description != null ? Text(task.description!) : null,
      trailing: Checkbox(
        value: task.status == TaskStatus.completed,
        onChanged: (bool? value) {
          // Toggle task status
          final updatedTask = task.copyWith(
            status: value == true ? TaskStatus.completed : TaskStatus.pending,
            completedAt: value == true ? DateTime.now() : null,
          );

          ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
        },
      ),
      // Optional: Add a delete action
      onLongPress: () {
        // Confirm delete dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (task.id != null) {
                    ref
                        .read(taskNotifierProvider.notifier)
                        .deleteTask(task.id!);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Additional views for tablet layout, task details, etc. can be added here
