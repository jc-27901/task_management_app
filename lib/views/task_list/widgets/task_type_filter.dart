part of '../task_list_view.dart';

class TaskTypeFilter extends StatelessWidget {
  final Set<TaskType> selectedTaskTypes;
  final Function(TaskType, bool) onTaskTypeSelected;

  const TaskTypeFilter({
    super.key,
    required this.selectedTaskTypes,
    required this.onTaskTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: TaskType.values.map((TaskType taskType) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(taskType.name),
                selected: selectedTaskTypes.contains(taskType),
                onSelected: (bool selected) {
                  onTaskTypeSelected(taskType, selected);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}