import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../l10n/app_localizations.dart';

class AITabScreen extends StatefulWidget {
  const AITabScreen({super.key});

  @override
  State<AITabScreen> createState() => _AITabScreenState();
}

class _AITabScreenState extends State<AITabScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final FirebaseFunctions _functions;

  final List<_ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    _messages.add(const _ChatMessage(text: '', isUser: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_QuickAction> _quickActions(AppLocalizations l10n) {
    return [
      _QuickAction(
        icon: Icons.calculate_outlined,
        title: l10n.aiCalculateMaterial,
        subtitle: l10n.aiCalculateMaterialSubtitle,
      ),
      _QuickAction(
        icon: Icons.receipt_long_outlined,
        title: l10n.aiCreateEstimate,
        subtitle: l10n.aiCreateEstimateSubtitle,
      ),
      _QuickAction(
        icon: Icons.photo_camera_outlined,
        title: l10n.aiAnalyzePhoto,
        subtitle: l10n.aiAnalyzePhotoSubtitle,
      ),
      _QuickAction(
        icon: Icons.lightbulb_outline,
        title: l10n.aiRepairAdvice,
        subtitle: l10n.aiRepairAdviceSubtitle,
      ),
    ];
  }

  Future<void> _sendMessage(
    AppLocalizations l10n, [
    String? presetMessage,
  ]) async {
    if (_isLoading) return;

    final text = (presetMessage ?? _controller.text).trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));

      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final callable = _functions.httpsCallable('brivoraAI');

      final result = await callable.call(<String, dynamic>{'message': text});

      final data = result.data;

      if (data is! Map) {
        throw Exception('AI вернул некорректный ответ.');
      }

      final response = data['message'];

      if (response is! String || response.trim().isEmpty) {
        throw Exception('AI вернул пустой ответ.');
      }

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: response.trim(), isUser: false));

        _isLoading = false;
      });

      _scrollToBottom();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: e.message?.isNotEmpty == true
                ? e.message!
                : 'Не удалось получить ответ от AI.',
            isUser: false,
          ),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Ошибка подключения к Brivora AI: $e',
            isUser: false,
          ),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = colors.surface;
    final primaryColor = colors.primary;
    final primaryContainer = colors.primaryContainer;
    final textPrimary = colors.onSurface;
    final textSecondary = colors.onSurfaceVariant;
    final borderColor = colors.outline.withValues(alpha: 0.55);

    final quickActions = _quickActions(l10n);

    final hasOnlyInitialMessage =
        _messages.length == 1 && _messages.first.text.isEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              l10n: l10n,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
            ),
            Expanded(
              child: hasOnlyInitialMessage
                  ? _buildInitialState(
                      l10n: l10n,
                      quickActions: quickActions,
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      primaryContainer: primaryContainer,
                      isDark: isDark,
                    )
                  : _buildMessages(
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                    ),
            ),
            _buildInputArea(
              l10n: l10n,
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required AppLocalizations l10n,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiAssistant,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const _OnlineDot(),
                    const SizedBox(width: 6),
                    Text(
                      l10n.online,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState({
    required AppLocalizations l10n,
    required List<_QuickAction> quickActions,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
    required Color primaryContainer,
    required bool isDark,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(
            l10n: l10n,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primaryColor: primaryColor,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aiWhatCanIDo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...quickActions.map(
            (action) => _buildQuickAction(
              action,
              onTap: () {
                _sendMessage(l10n, action.title);
              },
              surfaceColor: surfaceColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              borderColor: borderColor,
              primaryColor: primaryColor,
              primaryContainer: primaryContainer,
            ),
          ),
          const SizedBox(height: 18),
          _buildHint(
            l10n: l10n,
            textSecondary: textSecondary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard({
    required AppLocalizations l10n,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    final lightStart = isDark
        ? const Color(0xFF172554)
        : const Color(0xFFEFF6FF);

    final lightEnd = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    final cardBorder = isDark
        ? const Color(0xFF1E40AF)
        : const Color(0xFFDBEAFE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightStart, lightEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            l10n.aiWelcomeTitle,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            l10n.aiWelcomeDescription,
            style: TextStyle(fontSize: 14, height: 1.5, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    _QuickAction action, {
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
    required Color primaryContainer,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(action.icon, color: primaryColor, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint({
    required AppLocalizations l10n,
    required Color textSecondary,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.aiExampleHint,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages({
    required Color textPrimary,
    required Color textSecondary,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildLoadingBubble(
            primaryColor: primaryColor,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
          );
        }

        return _buildMessageBubble(
          _messages[index],
          textPrimary: textPrimary,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          primaryColor: primaryColor,
        );
      },
    );
  }

  Widget _buildLoadingBubble({
    required Color primaryColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF60A5FA)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 17,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: const SizedBox(
                width: 34,
                height: 18,
                child: _TypingIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    _ChatMessage message, {
    required Color textPrimary,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
  }) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 310),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF60A5FA)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 17,
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea({
    required AppLocalizations l10n,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
    required Color primaryColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: TextStyle(fontSize: 14, color: textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.aiMessageHint,
                  hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) {
                  _sendMessage(l10n);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;

              return GestureDetector(
                onTap: hasText && !_isLoading
                    ? () {
                        _sendMessage(l10n);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasText && !_isLoading
                        ? primaryColor
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          color: hasText
                              ? Colors.white
                              : textSecondary.withValues(alpha: 0.55),
                          size: 22,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final offset = (value + index * 0.2) % 1.0;

            final opacity = 0.35 + (0.65 * (1 - (offset - 0.5).abs() * 2));

            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
