import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../../../clients/domain/models/client.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../../finances/domain/models/project_finance.dart';
import '../../../finances/presentation/providers/project_finance_provider.dart';
import '../../../project_changes/domain/models/project_change.dart';
import '../../../project_changes/presentation/providers/project_change_provider.dart';
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
  late final ClientProvider _clientProvider;

  Project get project => _project;

  @override
  void initState() {
    super.initState();

    _project = widget.project;
    _clientProvider = ClientProvider();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      context.read<TasksProvider>().listenToProjectTasks(_project.id);
      await _clientProvider.loadClient(_project.id);
      await context.read<ProjectFinanceProvider>().load(_project.id);
      context.read<ProjectChangeProvider>().listen(_project.id);

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
  void dispose() {
    _clientProvider.dispose();
    super.dispose();
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

            _buildClientSection(context),

            const SizedBox(height: 20),

            _buildFinanceSection(context),

            const SizedBox(height: 20),

            _buildChangesSection(context),

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
                ? CachedNetworkImage(
                    imageUrl: project.coverImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildEmptyCover(context),
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

  Widget _buildClientSection(BuildContext context) {
    return ListenableBuilder(
      listenable: _clientProvider,
      builder: (context, _) {
        final clientProvider = _clientProvider;
        final client = clientProvider.clientForProject(project.id);
        return _buildClientCard(context, clientProvider, client);
      },
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    ClientProvider clientProvider,
    Client? client,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final clientTextColor = colorScheme.onSurface;
    final clientMutedColor = colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Клиент',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: clientTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (client != null)
                  IconButton(
                    tooltip: 'Изменить',
                    onPressed: () => _showClientDialog(context, client: client),
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (clientProvider.error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Не удалось загрузить клиента: ${clientProvider.error}',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            if (clientProvider.isLoading && client == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (client == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_add_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    'Клиент не добавлен',
                    style: TextStyle(color: clientTextColor),
                  ),
                  subtitle: Text(
                    'Добавьте данные заказчика',
                    style: TextStyle(color: clientMutedColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: clientMutedColor,
                  ),
                  onTap: () => _showClientDialog(context),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: clientTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (client.phone.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _callClient(client.phone),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  client.phone,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: clientTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (client.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: clientMutedColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              client.email,
                              style: TextStyle(color: clientMutedColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (client.comment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          client.comment,
                          style: TextStyle(color: clientMutedColor),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (client.phone.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => _callClient(client.phone),
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text('Позвонить'),
                          ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _confirmDeleteClient(context),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Удалить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClientDialog(
    BuildContext context, {
    Client? client,
  }) async {
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final commentController =
        TextEditingController(text: client?.comment ?? '');

    try {
      final formKey = GlobalKey<FormState>();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(client == null ? 'Добавить клиента' : 'Изменить клиента'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          enabled: !saving,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Имя *',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Введите имя клиента'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          enabled: !saving,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Телефон',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          enabled: !saving,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: commentController,
                          enabled: !saving,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Комментарий',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => saving = true);

                            final provider = _clientProvider;
                            if (client == null) {
                              await provider.createClient(
                                projectId: project.id,
                                name: nameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                comment: commentController.text,
                              );
                            } else {
                              await provider.updateClient(
                                projectId: project.id,
                                name: nameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                comment: commentController.text,
                              );
                            }

                            if (!mounted) return;
                            if (provider.error != null) {
                              setState(() => saving = false);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Не удалось сохранить клиента: ${provider.error}',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                          },
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Сохранить'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      commentController.dispose();
    }
  }

  Future<void> _confirmDeleteClient(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить клиента?'),
        content: const Text('Данные клиента будут удалены из проекта.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = _clientProvider;
    await provider.deleteClient(project.id);

    if (!mounted) return;

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось удалить клиента: ${provider.error}')),
      );
    }
  }

  Future<void> _callClient(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть приложение телефона')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось позвонить: $e')),
      );
    }
  }

  Widget _buildFinanceSection(BuildContext context) {
    final provider = context.watch<ProjectFinanceProvider>();
    final finance = provider.finance;
    final changesProvider = context.watch<ProjectChangeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (finance == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Деньги', style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Изменить',
                  onPressed: provider.isLoading
                      ? null
                      : () => _showFinanceDialog(context, finance),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _financeRow(
              context,
              'Плановая стоимость',
              finance.plannedAmount + changesProvider.approvedTotal,
            ),
            _financeRow(context, 'Получено', finance.receivedAmount),
            _financeRow(context, 'Расходы', finance.expensesAmount),
            const Divider(height: 24),
            _financeRow(context, 'Остаток к получению', finance.remainingAmount,
                emphasize: true),
            _financeRow(context, 'Прибыль', finance.profitAmount, emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _financeRow(
    BuildContext context,
    String label,
    double value, {
    bool emphasize = false,
  }) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(ProjectFinance.formatMoney(value), style: style),
        ],
      ),
    );
  }

  Future<void> _showFinanceDialog(
    BuildContext context,
    ProjectFinance finance,
  ) async {
    final planned = TextEditingController(text: finance.plannedAmount.round().toString());
    final received = TextEditingController(text: finance.receivedAmount.round().toString());
    final expenses = TextEditingController(text: finance.expensesAmount.round().toString());
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Деньги проекта'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _moneyField(planned, 'Плановая стоимость'),
                  const SizedBox(height: 12),
                  _moneyField(received, 'Получено'),
                  const SizedBox(height: 12),
                  _moneyField(expenses, 'Расходы'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final provider = this.context.read<ProjectFinanceProvider>();
                await provider.save(
                  projectId: project.id,
                  plannedAmount: _parseMoney(planned.text),
                  receivedAmount: _parseMoney(received.text),
                  expensesAmount: _parseMoney(expenses.text),
                );
                if (!mounted) return;
                if (provider.error != null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Не удалось сохранить финансы: ${provider.error}')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      );
    } finally {
      planned.dispose();
      received.dispose();
      expenses.dispose();
    }
  }

  TextFormField _moneyField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: '₸'),
      validator: (value) {
        if (_parseMoney(value ?? '') < 0) return 'Сумма не может быть отрицательной';
        return null;
      },
    );
  }

  double _parseMoney(String value) {
    return double.tryParse(value.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
  }

  Widget _buildChangesSection(BuildContext context) {
    final provider = context.watch<ProjectChangeProvider>();
    final items = provider.items;
    final finance = context.watch<ProjectFinanceProvider>().finance;
    final approved = provider.approvedTotal;
    final plan = (finance?.plannedAmount ?? 0) + approved;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.change_circle_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text('Изменения проекта', style: Theme.of(context).textTheme.titleMedium)),
            IconButton(onPressed: () => _showChangeDialog(context), icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('План с одобренными изменениями', style: Theme.of(context).textTheme.bodyMedium)),
            Text(ProjectFinance.formatMoney(plan), style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('Изменений пока нет'))
          else
            ...items.map((change) => _buildChangeTile(context, change)),
        ]),
      ),
    );
  }

  Widget _buildChangeTile(BuildContext context, ProjectChange change) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (change.status) {
      ProjectChangeStatus.approved => Colors.green,
      ProjectChangeStatus.rejected => Colors.red,
      ProjectChangeStatus.waiting => Colors.orange,
    };
    final label = switch (change.status) {
      ProjectChangeStatus.approved => 'Одобрено',
      ProjectChangeStatus.rejected => 'Отклонено',
      ProjectChangeStatus.waiting => 'Ожидает',
    };
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: colorScheme.surfaceContainerHighest,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(change.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (change.comment.isNotEmpty) Text(change.comment),
          const SizedBox(height: 4),
          Text(ProjectFinance.formatMoney(change.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final status = switch (value) {
              'approved' => ProjectChangeStatus.approved,
              'rejected' => ProjectChangeStatus.rejected,
              _ => ProjectChangeStatus.waiting,
            };
            await context.read<ProjectChangeProvider>().save(change.copyWith(status: status));
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'approved', child: Text('Одобрить')),
            PopupMenuItem(value: 'waiting', child: Text('Вернуть в ожидание')),
            PopupMenuItem(value: 'rejected', child: Text('Отклонить')),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeDialog(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final comment = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Новое изменение'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Что изменилось?'), validator: (v) => v == null || v.trim().isEmpty ? 'Введите описание' : null),
              const SizedBox(height: 12),
              TextFormField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Сумма', suffixText: '₸'), validator: (v) => _parseMoney(v ?? '') <= 0 ? 'Введите сумму больше 0' : null),
              const SizedBox(height: 12),
              TextFormField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Комментарий')),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final now = DateTime.now();
                final change = ProjectChange(id: '', projectId: project.id, title: title.text.trim(), amount: _parseMoney(amount.text), status: ProjectChangeStatus.waiting, comment: comment.text.trim(), createdAt: now, updatedAt: now);
                await context.read<ProjectChangeProvider>().save(change);
                if (mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      );
    } finally {
      title.dispose();
      amount.dispose();
      comment.dispose();
    }
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
