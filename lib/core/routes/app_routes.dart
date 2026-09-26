import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/projects/domain/models/project.dart';

import '../../features/calculators/presentation/screens/calculators_screen.dart';
import '../../features/calculators/presentation/screens/tile_calculator_screen.dart';
import '../../features/calculators/presentation/screens/wallpaper_calculator_screen.dart';
import '../../features/calculators/presentation/screens/paint_calculator_screen.dart';
import '../../features/calculators/presentation/screens/laminate_calculator_screen.dart';
import '../../features/calculators/presentation/screens/concrete_calculator_screen.dart';

import '../../features/estimates/presentation/screens/estimate_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String profile = '/profile';

  static const String projectDetails = '/project-details';
  static const String estimate = '/estimate';

  static const String calculators = '/calculators';
  static const String tileCalculator = '/tile-calculator';
  static const String wallpaperCalculator = '/wallpaper-calculator';
  static const String paintCalculator = '/paint-calculator';
  static const String laminateCalculator = '/laminate-calculator';
  static const String concreteCalculator = '/concrete-calculator';

  static const String settings = '/settings';
  static const String subscription = '/subscription';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());

      case login:
        return _buildRoute(const LoginScreen());

      case register:
        return _buildRoute(const RegisterScreen());

      case home:
        return _buildRoute(const DashboardScreen());

      case calculators:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(CalculatorsScreen(project: project));
        }

      case tileCalculator:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(TileCalculatorScreen(project: project));
        }

      case wallpaperCalculator:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(WallpaperCalculatorScreen(project: project));
        }

      case paintCalculator:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(PaintCalculatorScreen(project: project));
        }

      case laminateCalculator:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(LaminateCalculatorScreen(project: project));
        }

      case concreteCalculator:
        {
          final project = settings.arguments as Project?;

          return _buildRoute(ConcreteCalculatorScreen(project: project));
        }

      case projectDetails:
        {
          final project = settings.arguments as Project;

          return _buildRoute(ProjectDetailsScreen(project: project));
        }

      case estimate:
        {
          final project = settings.arguments as Project;

          return _buildRoute(EstimateScreen(project: project));
        }

      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());

      case AppRoutes.subscription:
        return _buildRoute(const SubscriptionScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('Маршрут ${settings.name} не найден')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (context) => page);
  }
}
