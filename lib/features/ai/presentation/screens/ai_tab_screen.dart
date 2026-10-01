import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// AI is intentionally disabled in the first public Brivora release.
/// The tab stays visible so the feature can be introduced in a later update.
class AITabScreen extends StatelessWidget {
  const AITabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isKazakh = Localizations.localeOf(context).languageCode == 'kk';

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 38,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.aiAssistant,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isKazakh
                        ? 'AI функциясы әзірленуде.'
                        : 'Функция AI пока находится в разработке.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isKazakh
                        ? 'AI көмекшісін Brivora-ның келесі жаңартуларында қосамыз. '
                          'Қазір жөндеу жұмыстарын, тапсырмаларды, сметаларды және '
                          'қаржыны басқаруға арналған негізгі құралдардың барлығы қолжетімді.'
                        : 'Мы добавим AI-помощника в следующих обновлениях Brivora. '
                          'Сейчас доступны все основные инструменты для управления '
                          'ремонтом, задачами, сметами и финансами.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.update_rounded,
                          color: colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isKazakh
                                ? 'AI келесі жаңартуларда пайда болады.'
                                : 'AI появится в следующих обновлениях.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
