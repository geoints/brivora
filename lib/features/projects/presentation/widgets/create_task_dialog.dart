import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/task.dart';
import '../providers/tasks_provider.dart';

class CreateTaskDialog extends StatefulWidget {
  final String projectId;

  const CreateTaskDialog({super.key, required this.projectId});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  TaskPriority _priority = TaskPriority.normal;
  DateTime? _deadline;
  bool _isSaving = false;

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (!mounted || picked == null) return;

    setState(() => _deadline = picked);
  }

  Future<void> _saveTask() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    final task = Task(
      id: '',
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: TaskStatus.active,
      priority: _priority,
      createdAt: DateTime.now(),
      deadline: _deadline,
      completedAt: null,
    );

    try {
      await context.read<TasksProvider>().createTask(task);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить задачу: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Новая задача'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isSaving,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              enabled: !_isSaving,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              items: TaskPriority.values.map((value) {
                return DropdownMenuItem<TaskPriority>(
                  value: value,
                  child: Text(value.displayName),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Приоритет'),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _priority = value);
                    },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadline != null
                        ? 'Срок: ${_formatDate(_deadline!)}'
                        : 'Срок не выбран',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _isSaving ? null : _pickDeadline,
                  child: const Text('Выбрать'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _canSave ? _saveTask : null,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
