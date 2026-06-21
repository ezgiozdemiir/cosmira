import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/numerology_calculator.dart';
import '../providers/numerology_provider.dart';

class NumerologyScreen extends ConsumerWidget {
  const NumerologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userNumerologyProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: AppColors.textPrimary),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 4),
                          Text('num_title'.tr(),
                              style: AppTextStyles.headlineLarge),
                        ],
                      ),
                      Text(
                        'num_subtitle'.tr(),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // ── Personal analysis ──
                      if (result == null)
                        _NoProfileCard()
                      else ...[
                        _LifePathCard(number: result.lifePathNumber)
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideY(begin: 0.08),
                        const SizedBox(height: 10),
                        if (result.expressionNumber > 0) ...[
                          _SecondaryRow(
                            label: 'num_expression_label'.tr(),
                            number: result.expressionNumber,
                            icon: Icons.auto_awesome,
                            color: AppColors.auraViolet,
                            delay: 200.ms,
                          ),
                          const SizedBox(height: 8),
                          _SecondaryRow(
                            label: 'num_soul_urge_label'.tr(),
                            number: result.soulUrgeNumber,
                            icon: Icons.favorite_border,
                            color: AppColors.auraRose,
                            delay: 280.ms,
                          ),
                          const SizedBox(height: 8),
                          _SecondaryRow(
                            label: 'num_personality_label'.tr(),
                            number: result.personalityNumber,
                            icon: Icons.person_outline,
                            color: AppColors.auraTeal,
                            delay: 360.ms,
                          ),
                          const SizedBox(height: 8),
                          _SecondaryRow(
                            label: 'num_birthday_label'.tr(),
                            number: result.birthdayNumber,
                            icon: Icons.cake_outlined,
                            color: AppColors.auraAmber,
                            delay: 440.ms,
                          ),
                        ],
                        const SizedBox(height: 32),

                        // ── Family section ──
                        _FamilyTreeSection().animate().fadeIn(delay: 550.ms),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No profile card
// ─────────────────────────────────────────────────────────────────────────────

class _NoProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        children: [
          const Text('🔢', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('num_no_profile'.tr(),
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.accentGlow.withValues(alpha: 0.4)),
              ),
              child: Text('num_go_profile'.tr(),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.accentGlow)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Life Path hero card
// ─────────────────────────────────────────────────────────────────────────────

class _LifePathCard extends StatelessWidget {
  final int number;
  const _LifePathCard({required this.number});

  @override
  Widget build(BuildContext context) {
    final isMaster = number == 11 || number == 22 || number == 33;
    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E0A3A), Color(0xFF0D1133)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('num_life_path_label'.tr(),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textSecondary)),
              if (isMaster) ...[
                const SizedBox(width: 8),
                _MasterBadge(),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$number',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 72,
                  color: AppColors.accentGlow,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('num_${number}_keyword'.tr(),
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      'num_${number}_desc'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Secondary number row
// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryRow extends StatelessWidget {
  final String label;
  final int number;
  final IconData icon;
  final Color color;
  final Duration delay;

  const _SecondaryRow({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    if (number == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  Text('num_${number}_keyword'.tr(),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white)),
                ],
              ),
            ),
            Text('$number',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ).animate(delay: delay).fadeIn().slideX(begin: 0.04),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12102A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                Text('$number',
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            Text('num_${number}_keyword'.tr(),
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('num_${number}_desc'.tr(),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Family Tree Section
// ─────────────────────────────────────────────────────────────────────────────

class _FamilyTreeSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FamilyTreeSection> createState() => _FamilyTreeSectionState();
}

class _FamilyTreeSectionState extends ConsumerState<_FamilyTreeSection> {
  bool _showSpouseForm = false;
  bool _showChildForm = false;
  final _spouseNameCtrl = TextEditingController();
  final _childNameCtrl = TextEditingController();
  DateTime? _spouseDate;
  DateTime? _childDate;

  @override
  void dispose() {
    _spouseNameCtrl.dispose();
    _childNameCtrl.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime(1990),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (ctx, child) => Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentGlow,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1240),
            ),
          ),
          child: child!,
        ),
      );

  void _saveSpouse() {
    final name = _spouseNameCtrl.text.trim();
    if (name.isEmpty || _spouseDate == null) return;
    ref.read(spouseProvider.notifier).state =
        FamilyMember(name: name, birthDate: _spouseDate);
    setState(() {
      _showSpouseForm = false;
      _spouseNameCtrl.clear();
      _spouseDate = null;
    });
  }

  void _saveChild() {
    final name = _childNameCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(childrenProvider.notifier).update((list) => [
          ...list,
          FamilyMember(name: name, birthDate: _childDate),
        ]);
    setState(() {
      _showChildForm = false;
      _childNameCtrl.clear();
      _childDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userResult = ref.watch(userNumerologyProvider);
    final spouse = ref.watch(spouseProvider);
    final children = ref.watch(childrenProvider);
    final coupleNumber = ref.watch(coupleNumberProvider);
    final familyNumber = ref.watch(familyNumberProvider);

    final hasFamily = spouse != null || children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.cardBorder),
        const SizedBox(height: 16),
        Text('num_family_title'.tr(), style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text('num_family_subtitle'.tr(),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // ── Portrait row: user + spouse ────────────────────────────────────
        IntrinsicHeight(
         child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User portrait
            if (userResult != null)
              Expanded(
                child: _PortraitCard(
                  name: _firstName(ref),
                  lifePathNumber: userResult.lifePathNumber,
                  color: AppColors.accentGlow,
                  role: 'num_role_you'.tr(),
                ),
              ),
            if (userResult != null) const SizedBox(width: 10),

            // Spouse portrait or add button
            Expanded(
              child: spouse != null
                  ? _PortraitCard(
                      name: spouse.name,
                      lifePathNumber: spouse.lifePathNumber,
                      expressionNumber: spouse.expressionNumber,
                      color: AppColors.auraRose,
                      role: 'num_role_spouse'.tr(),
                      fullResult: spouse.fullResult,
                      onRemove: () =>
                          ref.read(spouseProvider.notifier).state = null,
                    )
                  : _showSpouseForm
                      ? _MemberForm(
                          nameController: _spouseNameCtrl,
                          selectedDate: _spouseDate,
                          dateRequired: true,
                          onPickDate: () async {
                            final d = await _pickDate();
                            if (d != null) setState(() => _spouseDate = d);
                          },
                          onSave: _saveSpouse,
                          onCancel: () =>
                              setState(() => _showSpouseForm = false),
                        )
                      : _AddButton(
                          label: 'num_add_spouse'.tr(),
                          icon: Icons.person_add_outlined,
                          color: AppColors.auraRose,
                          onTap: () => setState(() => _showSpouseForm = true),
                        ),
            ),
          ],
         ),
        ),

        // ── Couple analysis ────────────────────────────────────────────────
        if (coupleNumber != null) ...[
          const SizedBox(height: 16),
          _CoupleAnalysisCard(
            userLp: userResult!.lifePathNumber,
            spouseLp: spouse!.lifePathNumber!,
            coupleNumber: coupleNumber,
          ),
        ],

        // ── Children ──────────────────────────────────────────────────────
        if (children.isNotEmpty || _showChildForm) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Text('num_children_label'.tr(),
                  style: AppTextStyles.titleMedium),
              const Spacer(),
              if (!_showChildForm)
                GestureDetector(
                  onTap: () => setState(() => _showChildForm = true),
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.auraAmber, size: 22),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        for (int i = 0; i < children.length; i++) ...[
          _ChildCard(
            child: children[i],
            userLp: userResult?.lifePathNumber,
            spouseLp: spouse?.lifePathNumber,
            onRemove: () => ref.read(childrenProvider.notifier).update(
                  (list) => [...list.sublist(0, i), ...list.sublist(i + 1)],
                ),
          ),
          const SizedBox(height: 10),
        ],

        if (_showChildForm) ...[
          _MemberForm(
            nameController: _childNameCtrl,
            selectedDate: _childDate,
            dateRequired: false,
            onPickDate: () async {
              final d = await _pickDate();
              if (d != null) setState(() => _childDate = d);
            },
            onSave: _saveChild,
            onCancel: () => setState(() {
              _showChildForm = false;
              _childDate = null;
            }),
            namePlaceholder: 'num_child_name_hint'.tr(),
          ),
          const SizedBox(height: 10),
        ],

        if (!_showChildForm && children.isEmpty && spouse != null) ...[
          const SizedBox(height: 12),
          _AddButton(
            label: 'num_add_child'.tr(),
            icon: Icons.child_care_outlined,
            color: AppColors.auraAmber,
            onTap: () => setState(() => _showChildForm = true),
          ),
        ],

        if (children.isEmpty && !_showChildForm && spouse == null)
          const SizedBox.shrink(),

        if (children.isNotEmpty && !_showChildForm) ...[
          const SizedBox(height: 8),
          _AddButton(
            label: 'num_add_child'.tr(),
            icon: Icons.child_care_outlined,
            color: AppColors.auraAmber,
            onTap: () => setState(() => _showChildForm = true),
          ),
        ],

        // ── Family summary ─────────────────────────────────────────────────
        if (hasFamily && familyNumber != null) ...[
          const SizedBox(height: 24),
          _FamilySummaryCard(
            familyNumber: familyNumber,
            userResult: userResult,
            spouse: spouse,
            children: children,
          ),
        ],
      ],
    );
  }

  String _firstName(WidgetRef ref) {
    final profile = ref.read(userProfileProvider).valueOrNull;
    return profile?.firstName ?? profile?.displayName ?? 'num_role_you'.tr();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Portrait card (user / spouse)
// ─────────────────────────────────────────────────────────────────────────────

class _PortraitCard extends StatelessWidget {
  final String name;
  final int? lifePathNumber;
  final int? expressionNumber;
  final Color color;
  final String role;
  final VoidCallback? onRemove;
  final NumerologyResult? fullResult;

  const _PortraitCard({
    required this.name,
    required this.lifePathNumber,
    this.expressionNumber,
    required this.color,
    required this.role,
    this.onRemove,
    this.fullResult,
  });

  @override
  Widget build(BuildContext context) {
    final canExpand = fullResult != null;
    return GestureDetector(
      onTap: canExpand ? () => _showFullSheet(context) : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(role,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: color, fontSize: 9)),
                const Spacer(),
                if (canExpand)
                  Icon(Icons.info_outline,
                      size: 14, color: color.withValues(alpha: 0.6)),
                if (onRemove != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(Icons.close,
                        size: 14, color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name.split(' ').first,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (lifePathNumber != null) ...[
              Row(
                children: [
                  Text(
                    '$lifePathNumber',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'num_${lifePathNumber}_keyword'.tr(),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              if (expressionNumber != null && expressionNumber! > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${'num_expression_short'.tr()}: $expressionNumber',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
              if (canExpand) ...[
                const SizedBox(height: 8),
                Text(
                  'num_tap_details'.tr(),
                  style: AppTextStyles.labelSmall
                      .copyWith(color: color.withValues(alpha: 0.6), fontSize: 9),
                ),
              ],
            ] else
              Text(
                '?',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: color),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MemberDetailSheet(
        result: fullResult!,
        name: name,
        role: role,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Couple analysis card
// ─────────────────────────────────────────────────────────────────────────────

class _CoupleAnalysisCard extends StatelessWidget {
  final int userLp;
  final int spouseLp;
  final int coupleNumber;

  const _CoupleAnalysisCard({
    required this.userLp,
    required this.spouseLp,
    required this.coupleNumber,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A0A2A), Color(0xFF0D0D22)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💑', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('num_couple_label'.tr(),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.auraRose)),
            ],
          ),
          const SizedBox(height: 14),
          // LP row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LpChip(number: userLp, color: AppColors.accentGlow),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('+',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 18)),
              ),
              _LpChip(number: spouseLp, color: AppColors.auraRose),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('=',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 18)),
              ),
              _LpChip(number: coupleNumber, color: AppColors.auraAmber, big: true),
            ],
          ),
          const SizedBox(height: 14),
          // Couple number label
          Row(
            children: [
              Text(
                'num_couple_number_label'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                'num_${coupleNumber}_keyword'.tr(),
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.auraAmber),
              ),
              if (coupleNumber == 11 || coupleNumber == 22 || coupleNumber == 33) ...[
                const SizedBox(width: 6),
                _MasterBadge(),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'num_couple_${coupleNumber}_desc'.tr(),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _LpChip extends StatelessWidget {
  final int number;
  final Color color;
  final bool big;

  const _LpChip({required this.number, required this.color, this.big = false});

  @override
  Widget build(BuildContext context) {
    final size = big ? 44.0 : 36.0;
    final fontSize = big ? 20.0 : 16.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Child card
// ─────────────────────────────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  final FamilyMember child;
  final int? userLp;
  final int? spouseLp;
  final VoidCallback onRemove;

  const _ChildCard({
    required this.child,
    required this.userLp,
    required this.spouseLp,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lp = child.lifePathNumber;
    final exp = child.expressionNumber;

    final userCompat =
        (lp != null && userLp != null) ? NumerologyCalculator.reduce(lp + userLp!) : null;
    final spouseCompat =
        (lp != null && spouseLp != null) ? NumerologyCalculator.reduce(lp + spouseLp!) : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.auraAmber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.auraAmber.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👶', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(child.name,
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close,
                    size: 16, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (lp != null) ...[
            Row(
              children: [
                _LpChip(number: lp, color: AppColors.auraAmber),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('num_life_path_label'.tr(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                    Text('num_${lp}_keyword'.tr(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Row(
              children: [
                _LpChip(number: exp, color: AppColors.auraAmber),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('num_expression_label'.tr(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                    Text('num_${exp}_keyword'.tr(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (userCompat != null || spouseCompat != null)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (userCompat != null)
                  _CompatChip(
                    label: 'num_compat_with_you'.tr(),
                    number: userCompat,
                    color: AppColors.accentGlow,
                  ),
                if (spouseCompat != null)
                  _CompatChip(
                    label: 'num_compat_with_spouse'.tr(),
                    number: spouseCompat,
                    color: AppColors.auraRose,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CompatChip extends StatelessWidget {
  final String label;
  final int number;
  final Color color;

  const _CompatChip(
      {required this.label, required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 5),
          Text('$number',
              style: AppTextStyles.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(width: 3),
          Text('· ${('num_${number}_keyword'.tr())}',
              style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Family summary card
// ─────────────────────────────────────────────────────────────────────────────

class _FamilySummaryCard extends StatelessWidget {
  final int familyNumber;
  final NumerologyResult? userResult;
  final FamilyMember? spouse;
  final List<FamilyMember> children;

  const _FamilySummaryCard({
    required this.familyNumber,
    required this.userResult,
    required this.spouse,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isMaster =
        familyNumber == 11 || familyNumber == 22 || familyNumber == 33;

    // Collect all LP numbers for the visual row
    final allNumbers = <({String name, int number, Color color})>[];
    if (userResult != null) {
      allNumbers.add((
        name: 'num_role_you'.tr(),
        number: userResult!.lifePathNumber,
        color: AppColors.accentGlow,
      ));
    }
    if (spouse?.lifePathNumber != null) {
      allNumbers.add((
        name: spouse!.name.split(' ').first,
        number: spouse!.lifePathNumber!,
        color: AppColors.auraRose,
      ));
    }
    for (final child in children) {
      if (child.lifePathNumber != null) {
        allNumbers.add((
          name: child.name.split(' ').first,
          number: child.lifePathNumber!,
          color: AppColors.auraAmber,
        ));
      }
    }

    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1A2A), Color(0xFF0D0D22)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('num_family_power_label'.tr(),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.auraTeal)),
            ],
          ),
          const SizedBox(height: 14),

          // Members LP row
          if (allNumbers.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: allNumbers
                  .map((e) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LpChip(number: e.number, color: e.color),
                          const SizedBox(height: 4),
                          Text(e.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 9)),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 14),
          ],

          // Family number
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$familyNumber',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: AppColors.auraTeal,
                  height: 1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('num_family_number_label'.tr(),
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                        if (isMaster) ...[
                          const SizedBox(width: 6),
                          _MasterBadge(),
                        ],
                      ],
                    ),
                    Text(
                      'num_${familyNumber}_keyword'.tr(),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'num_family_${familyNumber}_desc'.tr(),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, height: 1.55),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add button
// ─────────────────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style:
                    AppTextStyles.labelLarge.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member form (spouse or child)
// ─────────────────────────────────────────────────────────────────────────────

class _MemberForm extends StatelessWidget {
  final TextEditingController nameController;
  final DateTime? selectedDate;
  final bool dateRequired;
  final VoidCallback onPickDate;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? namePlaceholder;

  const _MemberForm({
    required this.nameController,
    required this.selectedDate,
    required this.dateRequired,
    required this.onPickDate,
    required this.onSave,
    required this.onCancel,
    this.namePlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: namePlaceholder ?? 'num_family_name_hint'.tr(),
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textTertiary),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.accentGlow),
              ),
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day} / ${selectedDate!.month} / ${selectedDate!.year}'
                        : dateRequired
                            ? 'num_family_date_label'.tr()
                            : 'num_family_date_optional'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selectedDate != null
                          ? Colors.white
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Text('num_cancel'.tr(),
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.auraViolet, AppColors.accentGlow],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('num_save'.tr(),
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Master number badge
// ─────────────────────────────────────────────────────────────────────────────

class _MasterBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.auraAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.auraAmber.withValues(alpha: 0.5)),
      ),
      child: Text(
        'num_master'.tr(),
        style: AppTextStyles.labelSmall
            .copyWith(color: AppColors.auraAmber, fontSize: 9),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Member detail sheet — full numerological breakdown for spouse / child
// ─────────────────────────────────────────────────────────────────────────────

class _MemberDetailSheet extends StatelessWidget {
  final NumerologyResult result;
  final String name;
  final String role;
  final Color color;

  const _MemberDetailSheet({
    required this.result,
    required this.name,
    required this.role,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMaster = result.lifePathNumber == 11 ||
        result.lifePathNumber == 22 ||
        result.lifePathNumber == 33;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: color, fontSize: 10)),
                          Text(name,
                              style: AppTextStyles.headlineSmall
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Life Path hero
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('num_life_path_label'.tr(),
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: AppColors.textSecondary)),
                            if (isMaster) ...[
                              const SizedBox(width: 8),
                              _MasterBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${result.lifePathNumber}',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                color: color,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'num_${result.lifePathNumber}_keyword'.tr(),
                                    style: AppTextStyles.titleMedium
                                        .copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'num_${result.lifePathNumber}_desc'.tr(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary numbers
                  if (result.expressionNumber > 0) ...[
                    _SheetNumberRow(
                      label: 'num_expression_label'.tr(),
                      number: result.expressionNumber,
                      icon: Icons.auto_awesome,
                      color: AppColors.auraViolet,
                    ),
                    const SizedBox(height: 8),
                    _SheetNumberRow(
                      label: 'num_soul_urge_label'.tr(),
                      number: result.soulUrgeNumber,
                      icon: Icons.favorite_border,
                      color: AppColors.auraRose,
                    ),
                    const SizedBox(height: 8),
                    _SheetNumberRow(
                      label: 'num_personality_label'.tr(),
                      number: result.personalityNumber,
                      icon: Icons.person_outline,
                      color: AppColors.auraTeal,
                    ),
                    const SizedBox(height: 8),
                    _SheetNumberRow(
                      label: 'num_birthday_label'.tr(),
                      number: result.birthdayNumber,
                      icon: Icons.cake_outlined,
                      color: AppColors.auraAmber,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetNumberRow extends StatelessWidget {
  final String label;
  final int number;
  final IconData icon;
  final Color color;

  const _SheetNumberRow({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (number == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                Text('num_${number}_keyword'.tr(),
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 3),
                Text(
                  'num_${number}_desc'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary, height: 1.45),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$number',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
