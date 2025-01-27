part of '../task_list_view.dart';

class TaskAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final AppPreferences preferences;

  const TaskAppBar({super.key, required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

