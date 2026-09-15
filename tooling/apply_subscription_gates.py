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
    "            final activeProjects =\n                provider.getProjectCountByStatus(ProjectStatus.active);",
    "            final activeProjects =\n                provider.getProjectCountByStatus()[ProjectStatus.active] ?? 0;",
)
replace_once(
    projects,
    "          onCreateProject: (title, description) async {\n            await context.read<ProjectsProvider>().createProject(\n              title,\n              description: description,\n            );\n",
    "          onCreateProject: (title, description) async {\n            final provider = context.read<ProjectsProvider>();\n            final activeProjects =\n                provider.getProjectCountByStatus()[ProjectStatus.active] ?? 0;\n            final canCreate = await SubscriptionService.instance\n                .canCreateProject(activeProjects);\n\n            if (!canCreate) {\n              if (!mounted) return;\n              Navigator.of(context).pop();\n              await Navigator.pushNamed(context, AppRoutes.subscription);\n              return;\n            }\n\n            await provider.createProject(\n              title,\n              description: description,\n            );\n",
)

# Photos: Free users have up to five photos per project. Gallery selection is
# capped to the remaining slots; when no slots remain, open the existing
# subscription screen. Pro users are unrestricted.
photos = ROOT / "lib/features/photos/presentation/screens/photos_screen.dart"
replace_once(
    photos,
    "import '../../../projects/data/repositories/project_repository.dart';\n",
    "import '../../../projects/data/repositories/project_repository.dart';\nimport '../../../../core/routes/app_routes.dart';\nimport '../../../../core/services/subscription_service.dart';\n",
)
replace_once(
    photos,
    "                      onTap: () async {\n                        Navigator.pop(context);\n\n                        await provider.uploadPhoto(projectId);\n                      },",
    "                      onTap: () async {\n                        Navigator.pop(context);\n\n                        final photos = await provider.getPhotos(projectId).first;\n                        final isPro = await SubscriptionService.instance.isPro();\n\n                        if (!isPro && photos.length >= SubscriptionService.instance.photoLimit) {\n                          if (!context.mounted) return;\n                          await Navigator.pushNamed(context, AppRoutes.subscription);\n                          return;\n                        }\n\n                        final remaining = isPro\n                            ? null\n                            : SubscriptionService.instance.photoLimit - photos.length;\n                        await provider.uploadPhoto(projectId, maxPhotos: remaining);\n                      },",
)
replace_once(
    photos,
    "                      onTap: () async {\n                        Navigator.pop(context);\n\n                        await provider.uploadFromCamera(projectId);\n                      },",
    "                      onTap: () async {\n                        Navigator.pop(context);\n\n                        final photos = await provider.getPhotos(projectId).first;\n                        final isPro = await SubscriptionService.instance.isPro();\n\n                        if (!isPro && photos.length >= SubscriptionService.instance.photoLimit) {\n                          if (!context.mounted) return;\n                          await Navigator.pushNamed(context, AppRoutes.subscription);\n                          return;\n                        }\n\n                        await provider.uploadFromCamera(projectId);\n                      },",
)

provider = ROOT / "lib/features/photos/presentation/providers/photos_provider.dart"
replace_once(
    provider,
    "  Future<void> uploadPhoto(String projectId) async {",
    "  Future<void> uploadPhoto(String projectId, {int? maxPhotos}) async {",
)
replace_once(
    provider,
    "      await _repository.pickAndUploadPhoto(projectId);",
    "      await _repository.pickAndUploadPhoto(projectId, maxPhotos: maxPhotos);",
)

repository = ROOT / "lib/features/photos/data/repositories/photo_repository.dart"
replace_once(
    repository,
    "  Future<void> pickAndUploadPhoto(String projectId) async {",
    "  Future<void> pickAndUploadPhoto(String projectId, {int? maxPhotos}) async {",
)
replace_once(
    repository,
    "    // Все выбранные фотографии загружаются параллельно.\n    await Future.wait(\n      pickedFiles.map(\n        (picked) => _uploadFile(File(picked.path), projectId, user.uid),\n      ),\n    );",
    "    final filesToUpload = maxPhotos == null\n        ? pickedFiles\n        : pickedFiles.take(maxPhotos).toList();\n\n    // Все выбранные фотографии загружаются параллельно.\n    await Future.wait(\n      filesToUpload.map(\n        (picked) => _uploadFile(File(picked.path), projectId, user.uid),\n      ),\n    );",
)

# PDF: Free users can still export, but every page gets a visible Brivora
# watermark in the footer. Pro exports keep the clean footer.
estimate = ROOT / "lib/features/estimates/presentation/screens/estimate_screen.dart"
replace_once(
    estimate,
    "import '../../../projects/domain/models/project.dart';\n",
    "import '../../../projects/domain/models/project.dart';\nimport '../../../../core/services/subscription_service.dart';\n",
)
replace_once(
    estimate,
    "  Future<void> _exportToPdf(EstimateProvider provider) async {\n    try {\n      final pdf = pw.Document();",
    "  Future<void> _exportToPdf(EstimateProvider provider) async {\n    try {\n      final isPro = await SubscriptionService.instance.isPro();\n      final pdf = pw.Document();",
)
replace_once(
    estimate,
    "          margin: const pw.EdgeInsets.all(32),\n\n          build: (context) {",
    "          margin: const pw.EdgeInsets.all(32),\n\n          footer: (context) {\n            if (isPro) {\n              return pw.SizedBox();\n            }\n\n            return pw.Center(\n              child: pw.Container(\n                padding: const pw.EdgeInsets.symmetric(\n                  horizontal: 8,\n                  vertical: 3,\n                ),\n                decoration: pw.BoxDecoration(\n                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),\n                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),\n                ),\n                child: pw.Text(\n                  'BRIVORA • БЕСПЛАТНАЯ ВЕРСИЯ',\n                  style: pw.TextStyle(\n                    font: regularFont,\n                    fontSize: 7,\n                    color: PdfColors.grey500,\n                  ),\n                ),\n              ),\n            );\n          },\n\n          build: (context) {",
)

print("Subscription gates applied: AI + projects + photos + PDF watermark")
