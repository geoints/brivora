import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../domain/models/project.dart';
import '../providers/projects_provider.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  final bool autoOpenCreateDialog;
  final VoidCallback? onAutoOpenHandled;

  const ProjectsScreen({
    super.key,
    this.autoOpenCreateDialog = false,
    this.onAutoOpenHandled,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

enum _ProjectSort { newest, oldest, progress, nameAsc, nameDesc }

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _selectedFilter;
  _ProjectSort _sort = _ProjectSort.newest;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.autoOpenCreateDialog) {
        _openCreateProjectDialog();
        widget.onAutoOpenHandled?.call();
      }
    });
  }

  void _openCreateProjectDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreateProjectDialog(
          onCreateProject: (title, description) async {
            await context.read<ProjectsProvider>().createProject(
              title,
              description: description,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.projectCreated(title)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  List<Project> _visibleProjects(List<Project> source) {
    final query = _searchQuery.trim().toLowerCase();

    final result = source.where((project) {
      final matchesStatus =
          _selectedFilter == null || project.status == _selectedFilter;

      final title = project.title.toLowerCase();
      final description = project.description.toLowerCase();

      final matchesSearch =
          query.isEmpty || title.contains(query) || description.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    result.sort((a, b) {
      switch (_sort) {
        case _ProjectSort.newest:
          return b.createdAt.compareTo(a.createdAt);

        case _ProjectSort.oldest:
          return a.createdAt.compareTo(b.createdAt);

        case _ProjectSort.progress:
          return b.progress.compareTo(a.progress);

        case _ProjectSort.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());

        case _ProjectSort.nameDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      }
    });

    return result;
  }

  String _sortLabel(_ProjectSort sort, AppLocalizations l10n) {
    switch (sort) {
      case _ProjectSort.newest:
        return l10n.newestProjects;

      case _ProjectSort.oldest:
        return l10n.oldestProjects;

      case _ProjectSort.progress:
        return l10n.progress;

      case _ProjectSort.nameAsc:
        return l10n.nameAscending;

      case _ProjectSort.nameDesc:
        return l10n.nameDescending;
    }
  }

  @override
  void didUpdateWidget(covariant ProjectsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.autoOpenCreateDialog && widget.autoOpenCreateDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openCreateProjectDialog();
        widget.onAutoOpenHandled?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Consumer<ProjectsProvider>(
          builder: (context, provider, _) {
            final projects = _visibleProjects(provider.projects);

            if (provider.isLoading && provider.projects.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (provider.error != null && provider.projects.isEmpty) {
              return _buildErrorState(context, provider.error!);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isMobile = width < 700;
                final horizontalPadding = isMobile ? 16.0 : 28.0;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isMobile ? 18 : 28,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildHeader(context, isMobile),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildSearchAndFilters(
                          context,
                          isMobile,
                          provider,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        10,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10nFor(context).shownProjects(projects.length),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _selectedFilter != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = null;
                                  });
                                },
                                child: Text(l10nFor(context).reset),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (projects.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(context),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          28,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final project = projects[index];

                            return ProjectCard(
                              project: project,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.projectDetails,
                                  arguments: project,
                                );
                              },
                              onDelete: () async {
                                await context
                                    .read<ProjectsProvider>()
                                    .deleteProject(project.id);
                              },
                              onStatusChange: (status) async {
                                await context
                                    .read<ProjectsProvider>()
                                    .updateProjectStatus(project.id, status);
                              },
                            );
                          }, childCount: projects.length),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 390,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                mainAxisExtent: isMobile ? 455 : 430,
                              ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final buttonWidth = isMobile ? 96.0 : 150.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.projects,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.projectsManagementDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: buttonWidth,
          height: 48,
          child: FilledButton.icon(
            onPressed: _openCreateProjectDialog,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              isMobile ? l10n.newProjectShort : l10n.newProject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    bool isMobile,
    ProjectsProvider provider,
  ) {
    final counts = provider.getProjectCountByStatus();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildFilterBar(context, counts)),
              const SizedBox(width: 8),
              _buildSortButton(context),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildSearchField(context)),
        const SizedBox(width: 14),
        Flexible(child: _buildFilterBar(context, counts)),
        const SizedBox(width: 10),
        _buildSortButton(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(color: colors.onSurface),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: l10n.searchProjects,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, Map<ProjectStatus, int> counts) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final items = <({String label, int count, ProjectStatus? status})>[
      (
        label: l10n.all,
        count: counts.values.fold(0, (sum, value) => sum + value),
        status: null,
      ),
      (
        label: l10n.activeProjectsLabel,
        count: counts[ProjectStatus.active] ?? 0,
        status: ProjectStatus.active,
      ),
      (
        label: l10n.statusPlanning,
        count: counts[ProjectStatus.planning] ?? 0,
        status: ProjectStatus.planning,
      ),
      (
        label: l10n.completedProjectsLabel,
        count: counts[ProjectStatus.completed] ?? 0,
        status: ProjectStatus.completed,
      ),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: items.map((item) {
          final selected = _selectedFilter == item.status;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = item.status;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.08),
                            blurRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${item.label} ${item.count}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: 44,
      height: 44,
      child: PopupMenuButton<_ProjectSort>(
        initialValue: _sort,
        onSelected: (value) {
          setState(() {
            _sort = value;
          });
        },
        itemBuilder: (context) {
          return _ProjectSort.values.map((sort) {
            return PopupMenuItem<_ProjectSort>(
              value: sort,
              child: Text(_sortLabel(sort, l10n)),
            );
          }).toList();
        },
        padding: EdgeInsets.zero,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(Icons.sort_rounded, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: colors.error),
            const SizedBox(height: 16),
            Text(
              l10n.projectsLoadError,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<ProjectsProvider>().restartListening();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final hasFilters = _searchQuery.isNotEmpty || _selectedFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.folder_open_rounded,
                color: colors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? l10n.nothingFound : l10n.noProjectsYet,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasFilters
                  ? l10n.changeSearchOrFilter
                  : l10n.createFirstProjectDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (!hasFilters) ...[
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _openCreateProjectDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.createProject),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

AppLocalizations l10nFor(BuildContext context) {
  return AppLocalizations.of(context)!;
}
