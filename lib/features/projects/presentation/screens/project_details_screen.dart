import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../../data/repositories/project_repository.dart';

import '../providers/tasks_provider.dart';
import '../widgets/project_details_appbar.dart';

import '../../../notes/presentation/screens/notes_screen.dart';
import '../../../photos/presentation/screens/photos_screen.dart';

import '../../../../core/routes/app_routes.dart';

/// Экран с подробной информацией о проекте.
class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Project _project;

  Project get project => _project;

  @override
  void initState() {
    super.initState();

    _project = widget.project;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      context.read<TasksProvider>().listenToProjectTasks(_project.id);

      try {
        await ProjectRepository().markProjectAsOpened(_project.id);
      } catch (e) {
        debugPrint('MARK PROJECT AS OPENED ERROR: $e');
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.green;

      case ProjectStatus.planning:
        return Colors.blue;

      case ProjectStatus.completed:
        return Colors.purple;

      case ProjectStatus.archived:
        return Colors.grey;
    }
  }

  Future<void> _reloadProject() async {
    try {
      final updatedProject = await ProjectRepository().getProjectById(
        _project.id,
      );

      if (!mounted || updatedProject == null) {
        return;
      }

      setState(() {
        _project = updatedProject;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось обновить проект: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProjectDetailsAppBar(project: project),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить задачу'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),

            const SizedBox(height: 20),

            _buildTaskSection(context),

            const SizedBox(height: 20),

            _buildProjectSections(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasCover =
        project.coverImageUrl != null &&
        project.coverImageUrl!.trim().isNotEmpty;

    final statusColor = _getStatusColor(project.status);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: hasCover
                ? Image.network(
                    project.coverImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildEmptyCover(context);
                    },
                  )
                : _buildEmptyCover(context),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.status.shortName,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  project.description.trim().isNotEmpty
                      ? project.description
                      : 'Описание отсутствует',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Прогресс',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${(project.progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: project.progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      _formatDate(project.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCover(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    final tasks = tasksProvider.tasks;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Задачи', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(context, 'all', 'Все'),
                _buildFilterChip(context, 'active', 'Активные'),
                _buildFilterChip(context, 'inProgress', 'В процессе'),
                _buildFilterChip(context, 'completed', 'Выполненные'),
              ],
            ),

            const SizedBox(height: 16),

            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Нет задач для этого проекта',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else
              Column(
                children: tasks
                    .map((task) => _buildTaskCard(context, task))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final tasksProvider = context.read<TasksProvider>();

    final selected = tasksProvider.filter == value;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        tasksProvider.setFilter(value);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final tasksProvider = context.read<TasksProvider>();

    final statusColor = task.status == TaskStatus.completed
        ? Colors.green
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        leading: InkWell(
          onTap: () async {
            final nextStatus = task.status == TaskStatus.completed
                ? TaskStatus.active
                : TaskStatus.completed;

            try {
              await tasksProvider.updateTaskStatus(task, nextStatus);

              if (!mounted) return;

              await _reloadProject();
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Не удалось обновить задачу: $e')),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Icon(
              task.status == TaskStatus.completed
                  ? Icons.check
                  : Icons.radio_button_unchecked,
              color: statusColor,
            ),
          ),
        ),

        title: Text(task.title, style: Theme.of(context).textTheme.titleMedium),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text(
              task.description.isNotEmpty
                  ? task.description
                  : 'Описание отсутствует',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(task.priority.displayName),
                ),

                Text(
                  task.status.displayName,
                  style: TextStyle(color: statusColor),
                ),

                if (task.deadline != null)
                  Text('до ${_formatDate(task.deadline!)}'),
              ],
            ),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmAndDeleteTask(context, task),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить задачу?'),
          content: Text(
            'Задача «${task.title}» будет удалена '
            'без возможности восстановить.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    try {
      await context.read<TasksProvider>().deleteTask(task.id, project.id);

      if (!mounted) return;

      await _reloadProject();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось удалить задачу: $e')));
    }
  }

  Future<void> _showCreateTaskDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _CreateTaskDialog(projectId: project.id);
      },
    );

    if (!mounted) return;

    await _reloadProject();
  }

  Widget _buildProjectSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Разделы проекта', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.note_alt),
            title: const Text('Заметки'),
            subtitle: const Text('Записи и важная информация проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesScreen(projectId: project.id),
                ),
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Фото'),
            subtitle: const Text('Фото проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotosScreen(projectId: project.id),
                ),
              );

              if (!mounted) return;

              if (result == true) {
                await _reloadProject();
              }
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Калькуляторы'),
            subtitle: const Text('Расчёт материалов для проекта'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.calculators,
                arguments: project,
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Смета'),
            subtitle: const Text('Материалы, работа и расходы'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.estimate,
                arguments: project,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Отдельный экран-диалог создания задачи.
///
/// Вынесен из ProjectDetailsScreen специально для того,
/// чтобы жизненный цикл формы не зависел от StatefulBuilder
/// внутри showDialog.
class _CreateTaskDialog extends StatefulWidget {
  final String projectId;

  const _CreateTaskDialog({required this.projectId});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  late final TextEditingController _titleController;

  late final TextEditingController _descriptionController;

  TaskPriority _priority = TaskPriority.normal;

  DateTime? _deadline;

  bool _isSaving = false;

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

  bool get _canSave {
    return _titleController.text.trim().isNotEmpty && !_isSaving;
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

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _deadline = picked;
    });
  }

  Future<void> _saveTask() async {
    if (!_canSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

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

      setState(() {
        _isSaving = false;
      });

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
              onChanged: (_) {
                setState(() {});
              },
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
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _priority = value;
                      });
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
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
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
