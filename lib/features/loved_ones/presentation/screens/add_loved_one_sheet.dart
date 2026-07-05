import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/widgets/gender_selector.dart';
import '../../../onboarding/presentation/widgets/birth_data_form.dart';
import '../providers/loved_ones_provider.dart';
import 'loved_ones_list_screen.dart';

class AddLovedOneSheet extends ConsumerStatefulWidget {
  const AddLovedOneSheet({super.key});

  @override
  ConsumerState<AddLovedOneSheet> createState() => _AddLovedOneSheetState();
}

class _AddLovedOneSheetState extends ConsumerState<AddLovedOneSheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _birthCity = '';
  String? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _birthTime == null || _birthCity.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('lo_missing_birth_data'.tr())),
      );
      return;
    }

    final success = await ref.read(addLovedOneProvider.notifier).add(
          name: _nameController.text,
          gender: _gender,
          birthDate: _birthDate!,
          birthTime: _birthTime!,
          birthCity: _birthCity,
        );

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addLovedOneProvider);
    final isLoading = state is AsyncLoading;
    final error = state is AsyncError ? state.error.toString() : null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
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

              Text('lo_add'.tr(), style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text('lo_add_subtitle'.tr(), style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'lo_their_name'.tr(),
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.person_outline,
                      size: 18, color: AppColors.textTertiary),
                ),
                style: AppTextStyles.bodyMedium,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'lo_name_required'.tr()
                    : null,
              ),
              const SizedBox(height: 20),

              Text('form_gender'.tr(),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              GenderSelector(
                value: _gender,
                onChanged: (g) => setState(() => _gender = g),
              ),
              const SizedBox(height: 20),

              BirthDataForm(
                onDataChanged: (date, time, city) => setState(() {
                  _birthDate = date;
                  _birthTime = time;
                  _birthCity = city;
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'lo_accuracy_note'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),

              if (error != null) ...[
                Text(error,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: LovedOnesScreen.accentColor)),
                const SizedBox(height: 12),
              ],

              CosmicButton(
                label: isLoading ? 'lo_adding'.tr() : 'lo_add'.tr(),
                icon: Icons.card_giftcard_rounded,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
