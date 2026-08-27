import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../photos/data/repositories/photo_repository.dart';
import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoRepository _photoRepository = PhotoRepository();

  UserProfile _profile = const UserProfile();

  bool _isProfileLoading = true;
  bool _isAvatarLoading = false;

  int _photoCount = 0;

  static const Color primary = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsProvider>().listenToProjects();
    });

    _loadProfile();
    _loadPhotoCount();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isProfileLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _loadPhotoCount() async {
    try {
      final count = await _photoRepository.getUserPhotoCount();

      if (!mounted) return;

      setState(() {
        _photoCount = count;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _photoCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatistics(),
                  const SizedBox(height: 20),
                  _buildSettingsCard(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 14),
                  _buildVersion(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasName = _profile.fullName.isNotEmpty;
    final hasRole = _profile.roleLine.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Профиль',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAvatar(),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -3,
                top: -3,
                child: GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isAvatarLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: colors.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasName
                      ? _profile.fullName
                      : (_isProfileLoading ? 'Загрузка...' : 'Добавьте имя'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: hasName ? colors.onSurface : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Text(
              hasRole ? _profile.roleLine : 'Укажите должность и компанию',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontStyle: hasRole ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final url = _profile.avatarUrl;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return _buildInitials();
                },
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _profile.initials.isNotEmpty ? _profile.initials : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final projectsProvider = context.watch<ProjectsProvider>();

    final projectsCount = projectsProvider.projects.length;

    final activeProjectsCount =
        projectsProvider.getProjectCountByStatus()[ProjectStatus.active] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.folder_outlined,
              value: '$projectsCount',
              label: 'Проекты',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.photo_library_outlined,
              value: '$_photoCount',
              label: 'Фото',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.work_outline,
              value: '$activeProjectsCount',
              label: 'Активные',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 42,
      color: colors.outline.withValues(alpha: 0.35),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 21, color: primary),
        const SizedBox(height: 7),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 5,
            ),
            leading: _buildSettingsIcon(Icons.settings_outlined),
            title: Text(
              l10n.settings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Настройки приложения и языка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSettings,
          ),
          Divider(
            height: 1,
            indent: 72,
            color: colors.outline.withValues(alpha: 0.3),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 5,
            ),
            leading: _buildSettingsIcon(Icons.language_outlined),
            title: Text(
              l10n.language,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(l10n.russian),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSettings,
          ),
          Divider(
            height: 1,
            indent: 72,
            color: colors.outline.withValues(alpha: 0.3),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 5,
            ),
            leading: _buildSettingsIcon(Icons.notifications_none_outlined),
            title: Text(
              l10n.notifications,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Управление уведомлениями'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsIcon(IconData icon) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: primary, size: 21),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Widget _buildLogoutButton() {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Выйти из аккаунта',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildVersion() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Brivora • версия 1.0.0',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Выйти из аккаунта?'),
          content: const Text(
            'После выхода потребуется снова войти в Brivora.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось выйти: $e')));
    }
  }

  Future<void> _showAvatarOptions() async {
    final colors = Theme.of(context).colorScheme;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(sheetContext, 'gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(sheetContext, 'camera');
                },
              ),
              if (_profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Удалить фотографию'),
                  onTap: () {
                    Navigator.pop(sheetContext, 'delete');
                  },
                ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    switch (action) {
      case 'gallery':
        await _uploadAvatar(ImageSource.gallery);
        break;

      case 'camera':
        await _uploadAvatar(ImageSource.camera);
        break;

      case 'delete':
        await _deleteAvatar();
        break;
    }
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    if (!mounted) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final url = await _profileRepository.pickAndUploadAvatar(source);

      if (!mounted) return;

      if (url == null) {
        setState(() {
          _isAvatarLoading = false;
        });
        return;
      }

      setState(() {
        _profile = _profile.copyWith(avatarUrl: url);
        _isAvatarLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Аватар успешно обновлён')));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAvatarLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить аватар: $e')),
      );
    }
  }

  Future<void> _deleteAvatar() async {
    if (!mounted) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      await _profileRepository.deleteAvatar();

      if (!mounted) return;

      setState(() {
        _profile = _profile.copyWith(avatarUrl: '');
        _isAvatarLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Аватар удалён')));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAvatarLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось удалить аватар: $e')));
    }
  }

  Future<void> _showEditProfileDialog() async {
    final firstNameController = TextEditingController(text: _profile.firstName);

    final lastNameController = TextEditingController(text: _profile.lastName);

    final roleController = TextEditingController(text: _profile.role);

    final companyController = TextEditingController(text: _profile.companyInfo);

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Данные профиля'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameController,
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        hintText: 'Введите имя',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lastNameController,
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        hintText: 'Введите фамилию',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Должность',
                        hintText: 'Например: Прораб',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyController,
                      enabled: !isSaving,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'ИП / Компания',
                        hintText: 'Например: ИП Иванов',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() {
                            isSaving = true;
                          });

                          final updatedProfile = _profile.copyWith(
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            role: roleController.text.trim(),
                            companyInfo: companyController.text.trim(),
                          );

                          try {
                            await _profileRepository.saveUserProfile(
                              updatedProfile,
                            );

                            if (!mounted) return;

                            setState(() {
                              _profile = updatedProfile;
                            });

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Профиль сохранён')),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Не удалось сохранить: $e'),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    firstNameController.dispose();
    lastNameController.dispose();
    roleController.dispose();
    companyController.dispose();
  }
}
