import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/particle_background.dart';
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
                  _SignInButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signInWithApple(),
                    isPrimary: true,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
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
                  Text(
                    'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ).animate().fadeIn(delay: 1000.ms),
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
