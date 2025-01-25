import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/app_preferences.dart';
import 'package:task_management_app/providers/preference_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  TaskListViewState createState() => TaskListViewState();
}

class TaskListViewState extends ConsumerState<TaskListView> {
  // Track selected task type filters
  final Set<TaskType> _selectedTaskTypes = Set<TaskType>.from(TaskType.values);

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Task>> tasksAsync = ref.watch(taskNotifierProvider);
    final AppPreferences preferences = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          // Theme toggle and sort order buttons remain the same
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
      body: Column(
        children: [
          // Task Type Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: TaskType.values.map((TaskType taskType) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(taskType.name),
                      selected: _selectedTaskTypes.contains(taskType),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedTaskTypes.add(taskType);
                          } else {
                            _selectedTaskTypes.remove(taskType);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Apply sorting and filtering
                final List<Task> filteredAndSortedTasks = _filterAndSortTasks(
                    tasks, preferences.sortOrder, _selectedTaskTypes);
                return ListView.builder(
                  itemCount: filteredAndSortedTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredAndSortedTasks[index];
                    return TaskListItem(task: task);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Updated sorting and filtering method
  List<Task> _filterAndSortTasks(List<Task> tasks, TaskSortOrder sortOrder,
      Set<TaskType> selectedTaskTypes) {
    // First filter by task type
    final filteredTasks = tasks
        .where((task) => selectedTaskTypes.contains(task.taskType))
        .toList();

    // Then sort based on preferences
    switch (sortOrder) {
      case TaskSortOrder.byDate:
        return filteredTasks
          ..sort((a, b) =>
              (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt));
      case TaskSortOrder.byPriority:
        return filteredTasks
          ..sort((a, b) {
            final priorityOrder = {
              TaskPriority.high: 3,
              TaskPriority.medium: 2,
              TaskPriority.low: 1
            };

            final aPriority =
                priorityOrder[a.taskPriority ?? TaskPriority.low] ?? 1;
            final bPriority =
                priorityOrder[b.taskPriority ?? TaskPriority.low] ?? 1;

            return bPriority.compareTo(aPriority);
          });
    }
  }

  // Updated dialog to add new task
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController titleC = TextEditingController();
    final TextEditingController descriptionC = TextEditingController();

    // Track selected priority and task type
    ValueNotifier<TaskPriority?> priorityNotifier =
        ValueNotifier<TaskPriority?>(null);
    ValueNotifier<TaskType> taskTypeNotifier =
        ValueNotifier<TaskType>(TaskType.others);

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
              const SizedBox(height: 10),
              // Priority Selection
              ValueListenableBuilder<TaskPriority?>(
                valueListenable: priorityNotifier,
                builder: (context, selectedPriority, child) {
                  return DropdownButtonFormField<TaskPriority>(
                    value: selectedPriority,
                    hint: const Text('Select Priority'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: TaskPriority.values.map((TaskPriority priority) {
                      return DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Row(
                          children: [
                            _getPriorityIcon(priority),
                            const SizedBox(width: 8),
                            Text(_getPriorityText(priority)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (TaskPriority? newValue) {
                      priorityNotifier.value = newValue;
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              // Task Type Selection
              ValueListenableBuilder<TaskType>(
                valueListenable: taskTypeNotifier,
                builder: (context, selectedTaskType, child) {
                  return DropdownButtonFormField<TaskType>(
                    value: selectedTaskType,
                    hint: const Text('Select Task Type'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: TaskType.values.map((TaskType taskType) {
                      return DropdownMenuItem<TaskType>(
                        value: taskType,
                        child: Text(taskType.name),
                      );
                    }).toList(),
                    onChanged: (TaskType? newValue) {
                      if (newValue != null) {
                        taskTypeNotifier.value = newValue;
                      }
                    },
                  );
                },
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
                    taskPriority: priorityNotifier.value,
                    taskType: taskTypeNotifier.value,
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

  // Existing helper methods remain the same
  Icon _getPriorityIcon(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Icon(Icons.error, color: Colors.red);
      case TaskPriority.medium:
        return const Icon(Icons.warning, color: Colors.orange);
      case TaskPriority.low:
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return const Icon(Icons.priority_high, color: Colors.grey);
    }
  }

  String _getPriorityText(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      default:
        return 'No Priority';
    }
  }
}

// TaskListItem remains the same
class TaskListItem extends ConsumerWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _getPriorityIcon(task.taskPriority),
      title: Text(
        task.title,
        style: task.status == TaskStatus.completed
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: task.description != null
          ? Text('${task.description!} (${task.taskType.name})')
          : Text(task.taskType.name),
      trailing: Checkbox(
        value: task.status == TaskStatus.completed,
        onChanged: (bool? value) {
          final updatedTask = task.copyWith(
            status: value == true ? TaskStatus.completed : TaskStatus.pending,
            completedAt: value == true ? DateTime.now() : null,
          );

          ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
        },
      ),
      onLongPress: () {
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

  Icon _getPriorityIcon(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Icon(Icons.error, color: Colors.red);
      case TaskPriority.medium:
        return const Icon(Icons.warning, color: Colors.orange);
      case TaskPriority.low:
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return const Icon(Icons.priority_high, color: Colors.grey);
    }
  }
}
