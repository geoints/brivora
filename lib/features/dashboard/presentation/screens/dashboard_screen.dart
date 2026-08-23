import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../ai/presentation/screens/ai_tab_screen.dart';
import '../../../home/presentation/screens/home_tab_screen.dart';
import '../../../profile/presentation/screens/profile_tab_screen.dart';
import '../../../projects/presentation/screens/projects_tab_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Когда true — вкладка "Проекты" должна автоматически
  // открыть окно создания проекта.
  bool _autoOpenCreateProject = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeTabScreen(
        onCreateProject: _openCreateProjectFromHome,
        onViewAllProjects: _goToProjectsTab,
      ),
      ProjectsTabScreen(
        autoOpenCreateDialog: false,
        onAutoOpenHandled: _handleAutoOpenHandled,
      ),
      const AITabScreen(),
      const ProfileTabScreen(),
    ];
  }

  // ============================================================
  // НАВИГАЦИЯ
  // ============================================================

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // СОЗДАНИЕ ПРОЕКТА С ГЛАВНОЙ
  // ============================================================

  void _openCreateProjectFromHome() {
    setState(() {
      _autoOpenCreateProject = true;
      _selectedIndex = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _showCreateProjectDialogThroughProjectsTab();
    });
  }

  void _showCreateProjectDialogThroughProjectsTab() {
    // Эта функция оставлена как точка расширения.
    //
    // Сам диалог создания проекта сейчас контролируется
    // ProjectsTabScreen.
    //
    // При переключении на вкладку Projects экран остаётся
    // живым благодаря IndexedStack.
  }

  void _goToProjectsTab() {
    if (_selectedIndex == 1) {
      return;
    }

    setState(() {
      _selectedIndex = 1;
    });
  }

  void _handleAutoOpenHandled() {
    if (_autoOpenCreateProject) {
      setState(() {
        _autoOpenCreateProject = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        centerTitle: false,
      ),

      // IndexedStack НЕ уничтожает вкладки.
      //
      // Поэтому:
      // Главная сохраняет свои данные
      // Проекты сохраняют свои данные
      // AI сохраняет своё состояние
      // Профиль сохраняет аватар/имя/данные
      //
      // При переключении между вкладками ничего не
      // загружается заново.
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.projects,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: l10n.ai,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
