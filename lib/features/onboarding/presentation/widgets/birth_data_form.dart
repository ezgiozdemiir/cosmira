import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BirthDataForm extends ConsumerStatefulWidget {
  const BirthDataForm({super.key});

  @override
  ConsumerState<BirthDataForm> createState() => _BirthDataFormState();
}

class _BirthDataFormState extends ConsumerState<BirthDataForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('Birth Details', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'This information is used to calculate your unique natal chart.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          _FieldLabel('Date of Birth'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: _FieldBox(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Select your birth date',
                style: _selectedDate != null
                    ? AppTextStyles.bodyLarge
                    : AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Time of Birth'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 12, minute: 0),
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            child: _FieldBox(
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Select your birth time (optional)',
                style: _selectedTime != null
                    ? AppTextStyles.bodyLarge
                    : AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Birth City'),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Enter your birth city',
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
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
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
