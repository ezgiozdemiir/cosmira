import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../astrology/presentation/screens/birth_map_screen.dart';
import '../../domain/entities/loved_one.dart';
import '../providers/loved_one_reports_provider.dart';

/// Renders a Birth Map generated for a [LovedOne] rather than the current
/// user — reuses [BirthMapContent] (the same content/export-bar widget the
/// self Birth Map screen renders) since [LovedOne] duck-types identically
/// to `UserProfile` (matching sunSign/moonSign/risingSign/mcSign getters).
class LovedOneBirthMapScreen extends ConsumerStatefulWidget {
  final LovedOne lovedOne;
  const LovedOneBirthMapScreen({super.key, required this.lovedOne});

  static const cost = 200;

  @override
  ConsumerState<LovedOneBirthMapScreen> createState() =>
      _LovedOneBirthMapScreenState();
}

class _LovedOneBirthMapScreenState extends ConsumerState<LovedOneBirthMapScreen> {
  @override
  Widget build(BuildContext context) {
    final mapAsync = ref.watch(lovedOneBirthMapProvider(widget.lovedOne.id));
    final generateState =
        ref.watch(generateLovedOneBirthMapProvider(widget.lovedOne.id));

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: mapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildError(context),
            data: (map) {
              if (map != null) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: BirthMapContent(
                        map: map,
                        profile: widget.lovedOne,
                        subjectName: widget.lovedOne.name,
                      ),
                    ),
                  ],
                );
              }
              return _buildGenerate(context, generateState);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGenerate(BuildContext context, AsyncValue<void> generateState) {
    final isLoading = generateState is AsyncLoading;
    final error = generateState is AsyncError ? generateState.error.toString() : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.auraAmber, size: 40),
            const SizedBox(height: 16),
            Text(
              'lo_generate_birth_map_title'.tr(namedArgs: {'name': widget.lovedOne.name}),
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'lo_generate_birth_map_sub'.tr(namedArgs: {'cost': '${LovedOneBirthMapScreen.cost}'}),
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (error != null) ...[
              Text(error,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.auraRose)),
              const SizedBox(height: 12),
            ],
            CosmicButton(
              label: isLoading ? 'lo_generating'.tr() : 'lo_generate_birth_map'.tr(),
              icon: Icons.auto_awesome,
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(generateLovedOneBirthMapProvider(widget.lovedOne.id).notifier)
                      .generate(widget.lovedOne),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('bm_go_back'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.auraRose, size: 48),
            const SizedBox(height: 16),
            Text('bm_error_load'.tr(), style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('bm_go_back'.tr()),
            ),
          ],
        ),
      );
}
