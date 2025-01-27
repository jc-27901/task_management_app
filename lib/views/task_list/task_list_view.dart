import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/providers/app_preferences.dart';
import 'package:task_management_app/providers/preference_provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

// Import widget parts from separate files for better organization
part 'widgets/add_task_button.dart';
part 'widgets/task_list_item.dart';
part 'widgets/task_details.dart';
part 'widgets/task_type_filter.dart';
part 'widgets/task_app_bar.dart';

// Global state provider to track the currently selected task
// This is particularly useful for the tablet layout where we show task details
// final selectedTaskProvider = StateProvider<Task?>((ref) => null);

/// Main widget that handles the responsive layout of the task management app
class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  TaskListViewState createState() => TaskListViewState();
}

class TaskListViewState extends ConsumerState<TaskListView> {
  // Set to keep track of selected task types for filtering
  // Initially contains all task types
  final Set<TaskType> _selectedTaskTypes = Set<TaskType>.from(TaskType.values);

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder helps create responsive layouts based on available space
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define tablet breakpoint - devices wider than 600px are considered tablets
        final bool isTablet = constraints.maxWidth > 600;

        // Return appropriate layout based on screen width
        if (isTablet) {
          return TabletLayout(
            selectedTaskTypes: _selectedTaskTypes,
            onTaskTypeSelected: _updateSelectedTaskTypes,
          );
        } else {
          return MobileLayout(
            selectedTaskTypes: _selectedTaskTypes,
            onTaskTypeSelected: _updateSelectedTaskTypes,
          );
        }
      },
    );
  }

  /// Updates the set of selected task types when user toggles filter chips
  void _updateSelectedTaskTypes(TaskType taskType, bool selected) {
    setState(() {
      if (selected) {
        _selectedTaskTypes.add(taskType);
      } else {
        _selectedTaskTypes.remove(taskType);
      }
    });
  }
}

/// Layout for mobile devices - single column view
class MobileLayout extends ConsumerWidget {
  final Set<TaskType> selectedTaskTypes;
  final Function(TaskType, bool) onTaskTypeSelected;

  const MobileLayout({
    super.key,
    required this.selectedTaskTypes,
    required this.onTaskTypeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes in tasks and preferences
    final taskState = ref.watch(taskNotifierProvider);
    final tasksAsync = taskState.tasks;
    final AppPreferences preferences = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: TaskAppBar(preferences: preferences),
      body: Column(
        children: [
          // Filter chips for task types
          TaskTypeFilter(
            selectedTaskTypes: selectedTaskTypes,
            onTaskTypeSelected: onTaskTypeSelected,
          ),
          // List of tasks
          Expanded(
            child: TaskList(
              tasksAsync: tasksAsync,
              preferences: preferences,
              selectedTaskTypes: selectedTaskTypes,
              onTapTask: (_) {}, // No-op in mobile view since we don't show details
            ),
          ),
        ],
      ),
      floatingActionButton: AddTaskButton(),
    );
  }
}

/// Layout for tablet devices - split screen view
class TabletLayout extends ConsumerWidget {
  final Set<TaskType> selectedTaskTypes;
  final Function(TaskType, bool) onTaskTypeSelected;

  const TabletLayout({
    super.key,
    required this.selectedTaskTypes,
    required this.onTaskTypeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire task state
    final taskState = ref.watch(taskNotifierProvider);
    final AppPreferences preferences = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: TaskAppBar(preferences: preferences),
      body: Row(
        children: [
          // Left side - Task List (1/2 width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                TaskTypeFilter(
                  selectedTaskTypes: selectedTaskTypes,
                  onTaskTypeSelected: onTaskTypeSelected,
                ),
                Expanded(
                  child: TaskList(
                    tasksAsync: taskState.tasks,
                    preferences: preferences,
                    selectedTaskTypes: selectedTaskTypes,
                    onTapTask: (task) {
                      // Use the new selectTask method
                      ref.read(taskNotifierProvider.notifier).selectTask(task);
                    },
                    selectedTask: taskState.selectedTask,
                  ),
                ),
              ],
            ),
          ),
          // Right side - Task Details (1/2 width)
          Expanded(
            flex: 1,
            child: TaskDetails(task: taskState.selectedTask),
          ),
        ],
      ),
      floatingActionButton: AddTaskButton(),
    );
  }
}


class TaskList extends ConsumerWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final AppPreferences preferences;
  final Set<TaskType> selectedTaskTypes;
  final Function(Task) onTapTask;
  final Task? selectedTask;

  const TaskList({
    super.key,
    required this.tasksAsync,
    required this.preferences,
    required this.selectedTaskTypes,
    required this.onTapTask,
    this.selectedTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tasksAsync.when(
      data: (tasks) {
        final filteredAndSortedTasks =
        _filterAndSortTasks(tasks, preferences.sortOrder, selectedTaskTypes);
        return ListView.builder(
          itemCount: filteredAndSortedTasks.length,
          itemBuilder: (context, index) {
            final task = filteredAndSortedTasks[index];
            return TaskListItem(
              task: task,
              isSelected: selectedTask?.id == task.id,
              onTap: () => onTapTask(task),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  /// Filter tasks by selected task types and sort them according to preferences
  List<Task> _filterAndSortTasks(List<Task> tasks, TaskSortOrder sortOrder,
      Set<TaskType> selectedTaskTypes) {
    // First filter tasks by selected task types
    final filteredTasks = tasks
        .where((task) => selectedTaskTypes.contains(task.taskType))
        .toList();

    // Then sort tasks based on sort order preference
    switch (sortOrder) {
      case TaskSortOrder.byDate:
      // Sort by due date if available, otherwise use created date
        return filteredTasks
          ..sort((a, b) =>
              (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt));
      case TaskSortOrder.byPriority:
      // Sort by priority using numerical values for comparison
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
            return bPriority.compareTo(aPriority); // Higher priority first
          });
    }
  }
}