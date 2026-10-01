import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:brivora/features/projects/domain/models/task.dart';
import 'package:brivora/features/projects/presentation/providers/tasks_provider.dart';
import 'package:brivora/features/projects/presentation/widgets/create_task_dialog.dart';

class FakeTasksProvider extends TasksProvider {
  @override
  void listenToProjectTasks(String projectId) {}

  @override
  Future<Task> createTask(Task task) async => task;
}

void main() {
  testWidgets('Save button becomes enabled after entering a task title', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TasksProvider>(
          create: (_) => FakeTasksProvider(),
          child: const Scaffold(
            body: CreateTaskDialog(projectId: 'project-1'),
          ),
        ),
      ),
    );

    await tester.pump();

    final saveButton = find.widgetWithText(FilledButton, 'Сохранить');
    expect(saveButton, findsOneWidget);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Новая задача');
    await tester.pump();

    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  });
}
