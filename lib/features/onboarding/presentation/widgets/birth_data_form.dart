import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BirthDataForm extends ConsumerStatefulWidget {
  final void Function(DateTime? date, TimeOfDay? time, String city)
      onDataChanged;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? initialCity;

  const BirthDataForm({
    required this.onDataChanged,
    this.initialDate,
    this.initialTime,
    this.initialCity,
    super.key,
  });

  @override
  ConsumerState<BirthDataForm> createState() => _BirthDataFormState();
}

class _BirthDataFormState extends ConsumerState<BirthDataForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _cityController.text = widget.initialCity ?? '';
    _cityController.addListener(_notify);
    _notify();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onDataChanged(_selectedDate, _selectedTime, _cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('form_birth_date'.tr()),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
              _notify();
            }
          },
          child: _FieldBox(
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'form_birth_date_hint'.tr(),
              style: _selectedDate != null
                  ? AppTextStyles.bodyLarge
                  : AppTextStyles.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _FieldLabel('form_birth_time'.tr()),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
            );
            if (time != null) {
              setState(() => _selectedTime = time);
              _notify();
            }
          },
          child: _FieldBox(
            child: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'form_birth_time_hint'.tr(),
              style: _selectedTime != null
                  ? AppTextStyles.bodyLarge
                  : AppTextStyles.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _FieldLabel('form_birth_city'.tr()),
        const SizedBox(height: 8),
        TextField(
          controller: _cityController,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'form_birth_city_hint'.tr(),
            prefixIcon:
                const Icon(Icons.location_on_outlined, color: AppColors.textTertiary),
          ),
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

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
