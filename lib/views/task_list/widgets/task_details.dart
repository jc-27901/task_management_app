part of '../task_list_view.dart';

class TaskDetails extends StatelessWidget {
  final Task? task;

  const TaskDetails({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return const Center(
        child: Text('Select a task to view details'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task!.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (task!.description != null) ...[
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(task!.description!),
              const SizedBox(height: 16),
            ],
            Text(
              'Priority: ${_getPriorityText(task!.taskPriority)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Type: ${task!.taskType.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Status: ${task!.status.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Created: ${_formatDate(task!.createdAt)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (task!.completedAt != null)
              Text(
                'Completed: ${_formatDate(task!.completedAt!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}