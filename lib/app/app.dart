import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/providers/locale_controller.dart';
import '../core/routes/app_routes.dart';
import '../features/clients/presentation/providers/client_provider.dart';
import '../features/estimates/presentation/providers/estimate_provider.dart';
import '../features/finances/presentation/providers/project_finance_provider.dart';
import '../features/notes/presentation/providers/notes_provider.dart';
import '../features/photos/presentation/providers/photos_provider.dart';
import '../features/projects/presentation/providers/projects_provider.dart';
import '../features/projects/presentation/providers/tasks_provider.dart';
import '../features/project_changes/presentation/providers/project_change_provider.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'theme_controller.dart';

class BrivoraApp extends StatelessWidget {
  final LocaleController localeController;

  const BrivoraApp({super.key, required this.localeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..loadTheme(),
        ),
        ChangeNotifierProvider<LocaleController>.value(value: localeController),
        ChangeNotifierProvider<ProjectsProvider>(
          create: (_) => ProjectsProvider(),
        ),
        ChangeNotifierProvider<TasksProvider>(create: (_) => TasksProvider()),
        ChangeNotifierProvider<ProjectChangeProvider>(create: (_) => ProjectChangeProvider()),
        ChangeNotifierProvider<NotesProvider>(create: (_) => NotesProvider()),
        ChangeNotifierProvider<PhotosProvider>(create: (_) => PhotosProvider()),
        ChangeNotifierProvider<EstimateProvider>(
          create: (_) => EstimateProvider(),
        ),
        ChangeNotifierProvider<ProjectFinanceProvider>(
          create: (_) => ProjectFinanceProvider(),
        ),
        ChangeNotifierProvider<ClientProvider>(
          create: (_) => ClientProvider(),
        ),
      ],
      child: const _BrivoraAppContent(),
    );
  }
}

class _BrivoraAppContent extends StatelessWidget {
  const _BrivoraAppContent();

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();

    return MaterialApp(
      title: 'Brivora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      locale: localeController.locale,
      supportedLocales: const [Locale('ru'), Locale('kk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
