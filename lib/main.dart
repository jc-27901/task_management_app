// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/providers/app_preferences.dart';
import 'package:task_management_app/providers/preference_provider.dart';
import 'views/task_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences (optional, but can be useful for pre-loading)
  await SharedPreferences.getInstance();


  runApp(
    // Enabled Riverpod for the entire application
    const ProviderScope(
      child: TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends ConsumerWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesNotifierProvider);

    return MaterialApp(
      title: 'Task Manager',
      theme: preferences.theme == AppTheme.light
          ? ThemeData.light()
          : ThemeData.dark(),
      home: const TaskListView(),
    );
  }
}