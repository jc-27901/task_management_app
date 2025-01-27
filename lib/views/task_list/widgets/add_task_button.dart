part of '../task_list_view.dart';


class AddTaskButton extends ConsumerWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddTaskDialog(context, ref),
      child: const Icon(Icons.add),
    );
  }

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