import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../app/theme_controller.dart';
import '../../../../core/providers/locale_controller.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _currencyKey = 'brivora_currency';

  static final Uri _telegramUri = Uri.parse('https://t.me/BrivoraAI_bot');

  String _currency = '₸';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _currency = preferences.getString(_currencyKey) ?? '₸';
      _isLoading = false;
    });
  }

  Future<void> _setCurrency(String currency) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_currencyKey, currency);

    if (!mounted) return;

    setState(() {
      _currency = currency;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openTelegramSupport(LocaleController controller) async {
    try {
      final opened = await launchUrl(
        _telegramUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage(
          controller.isKazakh
              ? 'Telegram-ды ашу мүмкін болмады'
              : 'Не удалось открыть Telegram',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        controller.isKazakh
            ? 'Telegram-ды ашу мүмкін болмады'
            : 'Не удалось открыть Telegram',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.settings,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildSectionTitle(l10n.appearance, isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: l10n.appearance,
                  subtitle: _getThemeName(themeController.themeMode, l10n),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showThemeSelector(themeController, l10n);
                  },
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: l10n.language,
                  subtitle: localeController.isKazakh
                      ? l10n.kazakh
                      : l10n.russian,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showLanguageSelector(localeController, l10n);
                  },
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Валюта',
                  subtitle: _currency,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showCurrencySelector,
                ),
              ],
            ),

            const SizedBox(height: 28),

            const SizedBox(height: 28),

            _buildSectionTitle('Аккаунт', isDark),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.profile,
                  subtitle: localeController.isKazakh
                      ? 'Жеке деректер және компания туралы ақпарат'
                      : 'Личные данные и информация о компании',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              localeController.isKazakh ? 'Қолдау' : 'Поддержка',
              isDark,
            ),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: localeController.isKazakh ? 'Көмек' : 'Помощь',
                  subtitle: localeController.isKazakh
                      ? 'Сұрақтарға жауаптар және Brivora қолдауы'
                      : 'Ответы на вопросы и поддержка Brivora',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _openTelegramSupport(localeController);
                  },
                ),

                _buildDivider(),

                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: localeController.isKazakh
                      ? 'Brivora туралы'
                      : 'О Brivora',
                  subtitle: localeController.isKazakh
                      ? 'Қолданба нұсқасы және ақпарат'
                      : 'Версия приложения и информация',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showAbout(localeController);
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                l10n.appName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Center(
              child: Text(
                localeController.isKazakh
                    ? 'Сіздің құрылыс көмекшіңіз'
                    : 'Ваш строительный помощник',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Версия 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: isDark ? 0.85 : 0.75),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 21),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  size: 22,
                ),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 21),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightTheme;

      case ThemeMode.dark:
        return l10n.darkTheme;

      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  Future<void> _showThemeSelector(
    ThemeController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.appearance,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              _buildThemeOption(
                mode: ThemeMode.light,
                title: l10n.lightTheme,
                subtitle: l10n.lightTheme,
                icon: Icons.light_mode_outlined,
                selected: controller.themeMode == ThemeMode.light,
              ),

              _buildThemeOption(
                mode: ThemeMode.dark,
                title: l10n.darkTheme,
                subtitle: l10n.darkTheme,
                icon: Icons.dark_mode_outlined,
                selected: controller.themeMode == ThemeMode.dark,
              ),

              _buildThemeOption(
                mode: ThemeMode.system,
                title: l10n.systemTheme,
                subtitle: l10n.systemTheme,
                icon: Icons.brightness_auto_outlined,
                selected: controller.themeMode == ThemeMode.system,
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await controller.setThemeMode(selected);

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildThemeOption({
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        Navigator.pop(context, mode);
      },
    );
  }

  Future<void> _showLanguageSelector(
    LocaleController controller,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              _buildSelectionTile(
                icon: Icons.language,
                title: l10n.russian,
                selected: controller.isRussian,
                onTap: () {
                  Navigator.pop(context, 'ru');
                },
              ),

              _buildSelectionTile(
                icon: Icons.language,
                title: l10n.kazakh,
                selected: controller.isKazakh,
                onTap: () {
                  Navigator.pop(context, 'kk');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    if (selected == 'kk') {
      await controller.setKazakh();
    } else {
      await controller.setRussian();
    }

    if (!mounted) return;

    final message = selected == 'kk' ? 'Тіл сақталды' : 'Язык сохранён';

    _showMessage(message);
  }

  Future<void> _showCurrencySelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Валюта',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              _buildSelectionTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Тенге (₸)',
                selected: _currency == '₸',
                onTap: () {
                  Navigator.pop(context, '₸');
                },
              ),

              _buildSelectionTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Рубли (₽)',
                selected: _currency == '₽',
                onTap: () {
                  Navigator.pop(context, '₽');
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    await _setCurrency(selected);
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }

  void _showAbout(LocaleController controller) {
    final isKazakh = controller.isKazakh;

    showAboutDialog(
      context: context,
      applicationName: 'Brivora',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.construction_rounded, color: Colors.white),
      ),
      children: [
        Text(
          isKazakh
              ? 'Brivora — жобаларды, тапсырмаларды, есептеулерді және сметаларды басқаруға арналған құрылыс көмекшісі.'
              : 'Brivora — строительный помощник для управления проектами, задачами, расчётами и сметами.',
        ),
      ],
    );
  }
}
