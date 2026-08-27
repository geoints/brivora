import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/task_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/models/task.dart';
import '../../../photos/data/repositories/photo_repository.dart';
import '../../../photos/domain/models/photo.dart';
import '../../../estimates/data/repositories/estimate_repository.dart';
import '../../../estimates/domain/models/estimate_item.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ProjectStatus) onStatusChange;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  Color _statusColor(ColorScheme colors) {
    switch (project.status) {
      case ProjectStatus.active:
        return const Color(0xFF22C55E);

      case ProjectStatus.planning:
        return const Color(0xFFF59E0B);

      case ProjectStatus.completed:
        return colors.onSurfaceVariant;

      case ProjectStatus.archived:
        return colors.outline;
    }
  }

  String _statusLabel() {
    switch (project.status) {
      case ProjectStatus.active:
        return 'Активный';

      case ProjectStatus.planning:
        return 'Планирование';

      case ProjectStatus.completed:
        return 'Завершён';

      case ProjectStatus.archived:
        return 'Архив';
    }
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '₸${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '₸${(value / 1000).toStringAsFixed(0)}K';
    }

    return '₸${value.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progress = project.progress.clamp(0.0, 1.0);
    final statusColor = _statusColor(colors);

    final surface = colors.surface;
    final outline = colors.outlineVariant;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCover(context, colors),

                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildStatusBadge(context, colors, statusColor),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,
                      child: _buildMenu(context, colors),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title.isEmpty ? 'Без названия' : project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (project.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          project.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      Expanded(child: _buildProjectStats(context, colors)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, ColorScheme colors) {
    final url = project.coverImageUrl;

    if (url == null || url.isEmpty) {
      return Container(
        color: colors.primaryContainer,
        alignment: Alignment.center,
        child: Icon(
          Icons.business_rounded,
          color: colors.onPrimaryContainer,
          size: 42,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,

      placeholder: (_, _) {
        return Container(
          color: colors.surfaceContainerHighest,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        );
      },

      errorWidget: (_, _, _) {
        return Container(
          color: colors.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: colors.onSurfaceVariant,
            size: 34,
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    ColorScheme colors,
    Color statusColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? colors.surface.withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);

    final textColor = statusColor == colors.onSurfaceVariant
        ? colors.onSurface
        : statusColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _statusLabel(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, ColorScheme colors) {
    return PopupMenuButton<String>(
      tooltip: 'Действия проекта',

      onSelected: (value) {
        switch (value) {
          case 'active':
            onStatusChange(ProjectStatus.active);
            break;

          case 'planning':
            onStatusChange(ProjectStatus.planning);
            break;

          case 'completed':
            onStatusChange(ProjectStatus.completed);
            break;

          case 'archived':
            onStatusChange(ProjectStatus.archived);
            break;

          case 'delete':
            onDelete();
            break;
        }
      },

      itemBuilder: (_) => [
        const PopupMenuItem(value: 'active', child: Text('Активный')),
        const PopupMenuItem(value: 'planning', child: Text('Планирование')),
        const PopupMenuItem(value: 'completed', child: Text('Завершён')),
        const PopupMenuItem(value: 'archived', child: Text('Архив')),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text('Удалить', style: TextStyle(color: colors.error)),
        ),
      ],

      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Icon(Icons.more_vert_rounded, size: 20, color: colors.onSurface),
      ),
    );
  }

  Widget _buildProjectStats(BuildContext context, ColorScheme colors) {
    return StreamBuilder<List<Task>>(
      stream: TaskRepository().getProjectTasks(project.id),
      builder: (context, taskSnapshot) {
        final tasks = taskSnapshot.data ?? const <Task>[];

        return StreamBuilder<List<Photo>>(
          stream: PhotoRepository().getProjectPhotos(project.id),
          builder: (context, photoSnapshot) {
            final photos = photoSnapshot.data ?? const <Photo>[];

            return StreamBuilder<List<EstimateItem>>(
              stream: EstimateRepository().getProjectEstimatesStream(
                project.id,
              ),
              builder: (context, estimateSnapshot) {
                final estimateItems =
                    estimateSnapshot.data ?? const <EstimateItem>[];

                final completedTasks = tasks
                    .where((task) => task.status == TaskStatus.completed)
                    .length;

                final totalEstimate = estimateItems.fold<double>(
                  0,
                  (sum, item) => sum + item.totalPrice,
                );

                return Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        icon: Icons.check_box_outlined,
                        value: '$completedTasks/${tasks.length}',
                        label: 'Задачи',
                      ),
                    ),

                    _Divider(color: colors.outlineVariant),

                    Expanded(
                      child: _Stat(
                        icon: Icons.image_outlined,
                        value: '${photos.length}',
                        label: 'Фото',
                      ),
                    ),

                    _Divider(color: colors.outlineVariant),

                    Expanded(
                      child: _Stat(
                        icon: Icons.payments_outlined,
                        value: _formatMoney(totalEstimate),
                        label: 'Смета',
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: colors.onSurfaceVariant),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: color);
  }
}
