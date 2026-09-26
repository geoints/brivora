import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/screens/home_tab_screen.dart';
import '../../../profile/presentation/screens/profile_tab_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _openCreateProject = false;


  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openCreateProjectFromHome() {
    setState(() {
      _selectedIndex = 1;
      _openCreateProject = true;
    });
  }

  void _goToProjectsTab() {
    if (_selectedIndex == 1) return;
    setState(() => _selectedIndex = 1);
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTabScreen(
            onCreateProject: _openCreateProjectFromHome,
            onViewAllProjects: _goToProjectsTab,
          ),
          ProjectsScreen(
            autoOpenCreateDialog: _openCreateProject,
            onAutoOpenHandled: () {
              if (mounted && _openCreateProject) {
                setState(() => _openCreateProject = false);
              }
            },
          ),
          const ProfileTabScreen(),
        ],
      ),

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
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
