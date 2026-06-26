import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/compatibility_provider.dart';

class CompatibilityScreen extends ConsumerWidget {
  const CompatibilityScreen({super.key});

  static const _freeLimit = 2;
  static const _premiumLimit = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partners = ref.watch(partnersProvider);
    final isPremium =
        ref.watch(userProfileProvider).valueOrNull?.isPremium ?? false;
    final limit = isPremium ? _premiumLimit : _freeLimit;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('compat_title'.tr(),
                                style: AppTextStyles.headlineLarge)
                            .animate()
                            .fadeIn(),
                        const SizedBox(height: 4),
                        Text(
                          'compat_subtitle'.tr(),
                          style: AppTextStyles.bodyMedium,
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                  partners.maybeWhen(
                    data: (list) => list.isNotEmpty && list.length < limit
                        ? IconButton.filled(
                            onPressed: () => _showAddSheet(context),
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.auraRose,
                              foregroundColor: Colors.white,
                            ),
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          partners.when(
            data: (list) {
              if (list.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CosmicCard(
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_border,
                              size: 48, color: AppColors.auraRose),
                          const SizedBox(height: 16),
                          Text('compat_no_partners'.tr(),
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'compat_no_partners_sub'.tr(),
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CosmicButton(
                            label: 'compat_add_partner'.tr(),
                            icon: Icons.add,
                            onPressed: () => _showAddSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final partner = list[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      child: CosmicCard(
                        onTap: () => context.push(
                          '/compatibility/partner',
                          extra: partner,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppColors.auraRose.withValues(alpha: 0.2),
                              child: Text(
                                partner.sunSign.zodiacEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(partner.name,
                                      style: AppTextStyles.titleMedium),
                                  Text(
                                    '${partner.sunSign.zodiacName} • ${'compat_${partner.relationship}'.tr()}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideX(begin: 0.05),
                    );
                  },
                  childCount: list.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: Center(child: Text('compat_error'.tr())),
            ),
          ),
          // Pro upsell card — shown when free user has reached the partner limit
          partners.maybeWhen(
            data: (list) => !isPremium && list.length >= limit
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: _MorePartnersProCard()
                          .animate()
                          .fadeIn(delay: (list.length * 100).ms),
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddPartnerSheet(),
    );
  }
}

class _AddPartnerSheet extends ConsumerStatefulWidget {
  const _AddPartnerSheet();

  @override
  ConsumerState<_AddPartnerSheet> createState() => _AddPartnerSheetState();
}

class _AddPartnerSheetState extends ConsumerState<_AddPartnerSheet> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _relationship = 'romantic';
  DateTime? _birthDate;

  List<(String, String, String)> get _relationships => [
        ('romantic', '💕', 'compat_romantic'.tr()),
        ('friend', '🌟', 'compat_friend'.tr()),
        ('family', '👨‍👩‍👧', 'compat_family'.tr()),
        ('colleague', '🤝', 'compat_colleague'.tr()),
      ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995, 6, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'compat_select_birthday_hint'.tr(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.auraRose,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('compat_select_birthday_snack'.tr())),
      );
      return;
    }

    final success = await ref.read(addPartnerProvider.notifier).addPartner(
          name: _nameController.text,
          birthDate: _birthDate!,
          relationship: _relationship,
          birthCity: _cityController.text,
        );

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addPartnerProvider);
    final isLoading = state is AsyncLoading;
    final error = state is AsyncError ? state.error.toString() : null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('compat_add_partner'.tr(), style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text('compat_add_partner_subtitle'.tr(),
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration:
                  _inputDecoration('compat_their_name'.tr(), Icons.person_outline),
              style: AppTextStyles.bodyMedium,
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'compat_name_required'.tr()
                      : null,
            ),
            const SizedBox(height: 16),

            Text('compat_relationship'.tr(), style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _relationships.map((r) {
                final selected = _relationship == r.$1;
                return ChoiceChip(
                  label: Text('${r.$2} ${r.$3}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _relationship = r.$1),
                  selectedColor: AppColors.auraRose.withValues(alpha: 0.25),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? AppColors.auraRose
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.auraRose
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  backgroundColor: Colors.transparent,
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('compat_birthday'.tr(), style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _birthDate != null
                        ? AppColors.auraRose
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: 18,
                      color: _birthDate != null
                          ? AppColors.auraRose
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate != null
                          ? '${_birthDate!.day} ${'month_${_birthDate!.month}'.tr()} ${_birthDate!.year}'
                          : 'compat_select_birthday_hint'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _birthDate != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                  'compat_birth_city_opt'.tr(), Icons.location_on_outlined),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            if (error != null) ...[
              Text(error,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.auraRose)),
              const SizedBox(height: 12),
            ],

            CosmicButton(
              label: isLoading ? 'compat_adding'.tr() : 'compat_add_partner'.tr(),
              icon: Icons.favorite_border,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.textTertiary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.auraRose),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.auraRose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.auraRose),
        ),
      );
}

// ---------------------------------------------------------------------------
// Pro upsell card — more partners
// ---------------------------------------------------------------------------

class _MorePartnersProCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred fake partner rows
        CosmicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('compat_more_partners_title'.tr(),
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _fakePartnerRow('💜', 'compat_more_partners_hint_1'.tr()),
              const SizedBox(height: 10),
              _fakePartnerRow('💙', 'compat_more_partners_hint_2'.tr()),
            ],
          ),
        ),
        // Frosted overlay + lock
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.midnight.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.auraRose.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.auraRose.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: AppColors.auraRose, size: 28),
                ),
                const SizedBox(height: 14),
                Text('compat_more_partners_pro'.tr(),
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'compat_more_partners_pro_sub'.tr(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('compat_more_partners_cta'.tr(),
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fakePartnerRow(String emoji, String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.auraRose.withValues(alpha: 0.15),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.titleMedium),
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: 10,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
