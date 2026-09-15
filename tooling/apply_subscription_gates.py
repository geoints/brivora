from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"Patch target not found in {path}:\n{old}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


# AI: Free users are sent to the existing subscription screen before any
# message is added or the brivoraAI callable is invoked.
ai = ROOT / "lib/features/ai/presentation/screens/ai_tab_screen.dart"
replace_once(
    ai,
    "import '../../../../l10n/app_localizations.dart';\n",
    "import '../../../../l10n/app_localizations.dart';\nimport '../../../../core/routes/app_routes.dart';\nimport '../../../../core/services/subscription_service.dart';\n",
)
replace_once(
    ai,
    "    if (text.isEmpty) return;\n\n    setState(() {",
    "    if (text.isEmpty) return;\n\n    final isPro = await SubscriptionService.instance.isPro();\n\n    if (!isPro) {\n      if (!mounted) return;\n      await Navigator.pushNamed(context, AppRoutes.subscription);\n      return;\n    }\n\n    setState(() {",
)

# Projects: a newly created project starts as ProjectStatus.active, so Free
# users can create at most two active projects. Pro users are unrestricted.
projects = ROOT / "lib/features/projects/presentation/screens/projects_screen.dart"
replace_once(
    projects,
    "import '../../../../l10n/app_localizations.dart';\nimport 'package:provider/provider.dart';\n\nimport '../../../../core/routes/app_routes.dart';\n",
    "import '../../../../l10n/app_localizations.dart';\nimport 'package:provider/provider.dart';\n\nimport '../../../../core/routes/app_routes.dart';\nimport '../../../../core/services/subscription_service.dart';\n",
)
replace_once(
    projects,
    "          onCreateProject: (title, description) async {\n            await context.read<ProjectsProvider>().createProject(\n              title,\n              description: description,\n            );\n",
    "          onCreateProject: (title, description) async {\n            final provider = context.read<ProjectsProvider>();\n            final activeProjects =\n                provider.getProjectCountByStatus(ProjectStatus.active);\n            final canCreate = await SubscriptionService.instance\n                .canCreateProject(activeProjects);\n\n            if (!canCreate) {\n              if (!mounted) return;\n              Navigator.of(context).pop();\n              await Navigator.pushNamed(context, AppRoutes.subscription);\n              return;\n            }\n\n            await provider.createProject(\n              title,\n              description: description,\n            );\n",
)

print("Subscription gates applied: AI + project creation")
