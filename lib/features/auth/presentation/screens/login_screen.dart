import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/particle_background.dart';
import '../../../legal/legal_bottom_sheet.dart';
import '../../../legal/legal_documents.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: ParticleBackground(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Cosmira',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 48,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
                  const SizedBox(height: 8),
                  Text(
                    'Your cosmic companion',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accentGlow,
                      letterSpacing: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  const Spacer(flex: 3),
                  _AppleSignInButton().animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                  const SizedBox(height: 16),
                  _SignInButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signInWithGoogle(),
                    isPrimary: false,
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
                  const SizedBox(height: 24),
                  if (authState.isLoading)
                    const CircularProgressIndicator(color: AppColors.accentGlow),
                  const Spacer(),
                  _LegalLinks().animate().fadeIn(delay: 1000.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Apple Sign-In is only available on iOS natively; on web it requires a paid
// Apple Developer account (Services ID + private key). Shown as disabled on web.
class _AppleSignInButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const isWebPlatform = kIsWeb;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isWebPlatform
                ? null
                : () => ref.read(authControllerProvider.notifier).signInWithApple(),
            icon: const Icon(Icons.apple, size: 24, color: isWebPlatform ? Colors.black38 : Colors.black),
            label: const Text(
              'Continue with Apple',
              style: TextStyle(color: isWebPlatform ? Colors.black38 : Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWebPlatform ? Colors.white38 : Colors.white,
              disabledBackgroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        if (isWebPlatform)
          Positioned(
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentGlow.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Coming soon',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.accentGlow,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LegalLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTr = context.locale.languageCode == 'tr';
    final linkStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.accentGlow,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.accentGlow,
    );

    return Column(
      children: [
        Text(
          isTr
              ? 'Devam ederek aşağıdakileri kabul etmiş olursunuz:'
              : 'By continuing, you agree to our',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => showLegalBottomSheet(context, LegalDocType.terms),
              child: Text(
                isTr ? 'Kullanım Koşulları' : 'Terms of Service',
                style: linkStyle,
              ),
            ),
            const Text(' & ', style: AppTextStyles.bodySmall),
            GestureDetector(
              onTap: () => showLegalBottomSheet(context, LegalDocType.privacy),
              child: Text(
                isTr ? 'Gizlilik Politikası' : 'Privacy Policy',
                style: linkStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _SignInButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }
}
