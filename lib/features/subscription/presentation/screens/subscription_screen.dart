import 'package:flutter/material.dart';

import '../../../../core/services/subscription_service.dart';

enum SubscriptionPlan { free, monthly, annual }

enum SubscriptionCtaState { normal, pressed, loading, disabled }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.annual;
  SubscriptionCtaState _ctaState = SubscriptionCtaState.normal;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor {
    return _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  }

  Color get _cardColor {
    return _isDark ? const Color(0xFF1E293B) : Colors.white;
  }

  Color get _heroCardColor {
    return _isDark ? const Color(0xFF203452) : const Color(0xFFF7FAFF);
  }

  Color get _selectedCardColor {
    return _isDark ? const Color(0xFF233A5A) : const Color(0xFFEEF4FF);
  }

  Color get _borderColor {
    return _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  }

  Color get _textPrimary {
    return _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  }

  Color get _textSecondary {
    return _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  Color get _textMuted {
    return _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  }

  Color get _primary {
    return _isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
  }

  Color get _accent {
    return const Color(0xFFF59E0B);
  }

  Color get _success {
    return const Color(0xFF22C55E);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSubscriptionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSubscriptionStatus();
    }
  }

  Future<void> _refreshSubscriptionStatus() async {
    await SubscriptionService.instance.refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(children: [_buildContent(), _buildBottomCta()]),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAnnualCard(),
                const SizedBox(height: 12),
                _buildMonthlyCard(),
                const SizedBox(height: 12),
                _buildFreeCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Material(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите свой план',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Получите больше возможностей с Brivora Pro',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualCard() {
    final selected = _selectedPlan == SubscriptionPlan.annual;

    return _PlanCard(
      selected: selected,
      hero: true,
      backgroundColor: selected ? _selectedCardColor : _heroCardColor,
      borderColor: selected ? _primary : const Color(0xFFC8D8EE),
      onTap: () => _selectPlan(SubscriptionPlan.annual),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Badge(
                      text: 'ЛУЧШИЙ ВЫБОР',
                      backgroundColor: _accent,
                      foregroundColor: _isDark
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                    ),
                    _Badge(
                      text: '−32%',
                      backgroundColor: _isDark
                          ? const Color(0x1AF59E0B)
                          : const Color(0x12D4800A),
                      foregroundColor: _accent,
                      borderColor: _isDark
                          ? const Color(0x38F59E0B)
                          : const Color(0x38D4800A),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SelectionIndicator(
                selected: selected,
                primaryColor: _primary,
                borderColor: _borderColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'PRO',
                style: TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ГОДОВОЙ',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '31 900 ₸',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ год',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '≈ 2 658 ₸ / мес',
            style: TextStyle(
              color: _primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0x12F59E0B)
                  : const Color(0x0FD4800A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isDark
                    ? const Color(0x32F59E0B)
                    : const Color(0x32D4800A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Почти 4 месяца в подарок',
                  style: TextStyle(
                    color: _isDark
                        ? const Color(0xFFD4A040)
                        : const Color(0xFF996010),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Экономия ≈ 14 900 ₸',
                  style: TextStyle(
                    color: _isDark
                        ? const Color(0xFFA07828)
                        : const Color(0xFFB87820),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CardDivider(
            active: selected,
            primaryColor: _primary,
            borderColor: _borderColor,
          ),
          const SizedBox(height: 14),
          const _Feature(text: 'Безлимитные проекты', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'PDF-смета без водяного знака', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'Безлимитные фото', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'Все калькуляторы', available: true),
          const SizedBox(height: 10),
          const _Feature(text: '50 запросов ИИ / месяц', available: true),
        ],
      ),
    );
  }

  Widget _buildMonthlyCard() {
    final selected = _selectedPlan == SubscriptionPlan.monthly;

    return _PlanCard(
      selected: selected,
      backgroundColor: selected ? _selectedCardColor : _cardColor,
      borderColor: selected ? _primary : _borderColor,
      onTap: () => _selectPlan(SubscriptionPlan.monthly),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PRO',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'МЕСЯЧНЫЙ',
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '3 900 ₸',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/ мес',
                          style: TextStyle(color: _textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _SelectionIndicator(
                selected: selected,
                primaryColor: _primary,
                borderColor: _borderColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CardDivider(
            active: selected,
            primaryColor: _primary,
            borderColor: _borderColor,
          ),
          const SizedBox(height: 14),
          const _Feature(text: 'Безлимитные проекты', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'PDF-смета без водяного знака', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'Безлимитные фото', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'Все калькуляторы', available: true),
          const SizedBox(height: 10),
          const _Feature(text: '50 запросов ИИ / месяц', available: true),
        ],
      ),
    );
  }

  Widget _buildFreeCard() {
    final selected = _selectedPlan == SubscriptionPlan.free;

    return _PlanCard(
      selected: selected,
      backgroundColor: selected ? _selectedCardColor : _cardColor,
      borderColor: selected ? _primary : _borderColor,
      onTap: () => _selectPlan(SubscriptionPlan.free),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'БЕСПЛАТНЫЙ',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '0 ₸',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'навсегда',
                      style: TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _SelectionIndicator(
                selected: selected,
                primaryColor: _primary,
                borderColor: _borderColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CardDivider(
            active: selected,
            primaryColor: _primary,
            borderColor: _borderColor,
          ),
          const SizedBox(height: 14),
          const _Feature(text: '1–2 активных проекта', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'PDF-смета с водяным знаком', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'До 5 фото на проект', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'Все калькуляторы', available: true),
          const SizedBox(height: 10),
          const _Feature(text: 'ИИ-ассистент', available: false),
        ],
      ),
    );
  }

  Widget _buildBottomCta() {
    final isDisabled = _ctaState == SubscriptionCtaState.disabled;
    final isLoading = _ctaState == SubscriptionCtaState.loading;
    final isPressed = _ctaState == SubscriptionCtaState.pressed;

    final String label = _selectedPlan == SubscriptionPlan.free
        ? 'Продолжить с Free'
        : 'Выбрать Pro';

    final String note = switch (_selectedPlan) {
      SubscriptionPlan.free => 'Бесплатно, навсегда',
      SubscriptionPlan.monthly => '3 900 ₸ / мес',
      SubscriptionPlan.annual => '31 900 ₸ / год',
    };

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _backgroundColor.withValues(alpha: 0),
                _backgroundColor.withValues(alpha: 0.96),
                _backgroundColor,
              ],
              stops: const [0, 0.38, 0.72],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: isDisabled || isLoading
                      ? null
                      : (_) {
                          setState(() {
                            _ctaState = SubscriptionCtaState.pressed;
                          });
                        },
                  onTapUp: isDisabled || isLoading
                      ? null
                      : (_) {
                          setState(() {
                            _ctaState = SubscriptionCtaState.normal;
                          });
                          _handleCta();
                        },
                  onTapCancel: isDisabled || isLoading
                      ? null
                      : () {
                          setState(() {
                            _ctaState = SubscriptionCtaState.normal;
                          });
                        },
                  child: AnimatedScale(
                    scale: isPressed ? 0.98 : 1,
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDisabled ? _borderColor : _primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !isDisabled && !isPressed
                            ? [
                                BoxShadow(
                                  color: _primary.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                label,
                                style: TextStyle(
                                  color: isDisabled ? _textMuted : Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectPlan(SubscriptionPlan plan) {
    if (_ctaState == SubscriptionCtaState.loading) return;

    setState(() {
      _selectedPlan = plan;
      _ctaState = SubscriptionCtaState.normal;
    });
  }

  void _handleCta() {
    if (_ctaState == SubscriptionCtaState.disabled) return;

    setState(() {
      _ctaState = SubscriptionCtaState.loading;
    });

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        _ctaState = SubscriptionCtaState.normal;
      });
    });
  }
}

class _PlanCard extends StatelessWidget {
  final Widget child;
  final bool selected;
  final bool hero;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _PlanCard({
    required this.child,
    required this.selected,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: selected ? 1.7 : 1),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : hero
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.16 : 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _Badge({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;
  final Color primaryColor;
  final Color borderColor;

  const _SelectionIndicator({
    required this.selected,
    required this.primaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? primaryColor : Colors.transparent,
        border: Border.all(
          color: selected ? primaryColor : borderColor,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _CardDivider extends StatelessWidget {
  final bool active;
  final Color primaryColor;
  final Color borderColor;

  const _CardDivider({
    required this.active,
    required this.primaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: active ? primaryColor.withValues(alpha: 0.24) : borderColor,
    );
  }
}

class _Feature extends StatelessWidget {
  final String text;
  final bool available;

  const _Feature({required this.text, required this.available});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
    final muted = dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final textColor = dark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);

    return Row(
      children: [
        Icon(
          available ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color: available ? primary : muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: available ? textColor : muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
