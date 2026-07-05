import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gender_selector.dart';

class PersonalInfoForm extends StatefulWidget {
  final void Function(String firstName, String lastName, String? gender) onDataChanged;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialGender;

  const PersonalInfoForm({
    required this.onDataChanged,
    this.initialFirstName,
    this.initialLastName,
    this.initialGender,
    super.key,
  });

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.initialFirstName ?? '';
    _lastNameController.text = widget.initialLastName ?? '';
    _gender = widget.initialGender;
    _firstNameController.addListener(_notify);
    _lastNameController.addListener(_notify);
    _notify();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onDataChanged(_firstNameController.text, _lastNameController.text, _gender);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('form_first_name'.tr()),
        const SizedBox(height: 8),
        TextField(
          controller: _firstNameController,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(hintText: 'form_first_name_hint'.tr()),
        ),
        const SizedBox(height: 24),
        _FieldLabel('form_last_name'.tr()),
        const SizedBox(height: 8),
        TextField(
          controller: _lastNameController,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(hintText: 'form_last_name_hint'.tr()),
        ),
        const SizedBox(height: 24),
        _FieldLabel('form_gender'.tr()),
        const SizedBox(height: 8),
        GenderSelector(
          value: _gender,
          onChanged: (g) {
            setState(() => _gender = g);
            _notify();
          },
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
    );
  }
}
