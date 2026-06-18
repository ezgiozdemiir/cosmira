import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../providers/compatibility_provider.dart';

class CompatibilityScreen extends ConsumerWidget {
  const CompatibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partners = ref.watch(partnersProvider);

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
                        Text('Compatibility', style: AppTextStyles.headlineLarge)
                            .animate()
                            .fadeIn(),
                        const SizedBox(height: 4),
                        Text(
                          'Explore your cosmic connections',
                          style: AppTextStyles.bodyMedium,
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                  partners.maybeWhen(
                    data: (list) => list.isNotEmpty
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
                          Text('No partners yet',
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Add someone to discover your cosmic compatibility.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CosmicButton(
                            label: 'Add Partner',
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
                                    '${partner.sunSign.capitalize} • ${partner.relationship.capitalize}',
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
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(child: Text('Error loading partners')),
            ),
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

// ---------------------------------------------------------------------------
// Add Partner bottom sheet
// ---------------------------------------------------------------------------

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

  static const _relationships = [
    ('romantic', '💕', 'Romantic'),
    ('friend', '🌟', 'Friend'),
    ('family', '👨‍👩‍👧', 'Family'),
    ('colleague', '🤝', 'Colleague'),
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
      helpText: 'Select their birthday',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
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
        const SnackBar(content: Text('Please select their birthday')),
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
            // Handle
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

            Text('Add Partner', style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text('Discover your cosmic compatibility',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Their name', Icons.person_outline),
              style: AppTextStyles.bodyMedium,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Relationship chips
            const Text('Relationship', style: AppTextStyles.labelLarge),
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

            // Birthday
            const Text('Birthday', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          ? '${_birthDate!.day} ${_monthName(_birthDate!.month)} ${_birthDate!.year}'
                          : 'Select their birthday',
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

            // Birth city (optional)
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                  'Birth city (optional)', Icons.location_on_outlined),
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
              label: isLoading ? 'Adding…' : 'Add Partner',
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

  String _monthName(int month) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][month];
}
