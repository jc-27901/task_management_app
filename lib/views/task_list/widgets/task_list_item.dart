part of '../task_list_view.dart';


class TaskListItem extends ConsumerWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskListItem({
    super.key,
    required this.task,
    this.isSelected = false,
    required this.onTap,
  });

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
      tileColor: isSelected ? Theme.of(context).highlightColor : null,
      onTap: onTap,
      trailing: Checkbox(
        value: task.status == TaskStatus.completed,
        onChanged: (bool? value) {
          final updatedTask = task.copyWith(
            status: value == true ? TaskStatus.completed : TaskStatus.pending,
            completedAt: value == true ? DateTime.now() : null,
          );
          ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
          ref.read(taskNotifierProvider.notifier).selectTask(task);
        },
      ),
      onLongPress: () => _showDeleteDialog(context, ref),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
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
                ref.read(taskNotifierProvider.notifier).deleteTask(task.id!);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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