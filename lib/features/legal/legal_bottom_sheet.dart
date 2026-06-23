import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'legal_documents.dart';

void showLegalBottomSheet(BuildContext context, LegalDocType type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LegalBottomSheet(
      type: type,
      languageCode: context.locale.languageCode,
    ),
  );
}

class _LegalBottomSheet extends StatelessWidget {
  final LegalDocType type;
  final String languageCode;

  const _LegalBottomSheet({
    required this.type,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final sections = LegalDocuments.get(type, languageCode);
    final title = LegalDocuments.docTitle(type, languageCode);
    final effectiveDate = LegalDocuments.effectiveDate(languageCode);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.cardBorder),
            left: BorderSide(color: AppColors.cardBorder),
            right: BorderSide(color: AppColors.cardBorder),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          effectiveDate,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),
            // Scrollable legal content
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                itemCount: sections.length,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                    height: 1,
                  ),
                ),
                itemBuilder: (_, i) => _SectionTile(section: sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final LegalSection section;
  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.accentGlow,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          section.body,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
