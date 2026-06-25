import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../legal/legal_bottom_sheet.dart';
import '../../../legal/legal_documents.dart';
import '../../../../core/providers/language_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: _LoginBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
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
                      context.tr('login_tagline'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentGlow,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                    const Spacer(flex: 3),
                    _AppleSignInButton().animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),
                    _SignInButton(
                      label: context.tr('login_google'),
                      icon: Icons.g_mobiledata,
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signInWithGoogle(),
                      isPrimary: false,
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),
                    _SignInButton(
                      label: context.tr('login_email'),
                      icon: Icons.email_outlined,
                      onPressed: () => _showEmailAuthSheet(context, ref),
                      isPrimary: false,
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                    const SizedBox(height: 24),
                    if (authState.isLoading)
                      const CircularProgressIndicator(color: AppColors.accentGlow),
                    const Spacer(),
                    _LegalLinks().animate().fadeIn(delay: 1000.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: _LanguageToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showEmailAuthSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EmailAuthSheet(),
  );
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
            label: Text(
              context.tr('login_apple'),
              style: const TextStyle(color: isWebPlatform ? Colors.black38 : Colors.black),
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
                context.tr('login_coming_soon'),
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
    final linkStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.accentGlow,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.accentGlow,
    );

    return Column(
      children: [
        Text(
          context.tr('login_agree'),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => showLegalBottomSheet(context, LegalDocType.terms),
              child: Text(context.tr('login_terms'), style: linkStyle),
            ),
            const Text(' & ', style: AppTextStyles.bodySmall),
            GestureDetector(
              onTap: () => showLegalBottomSheet(context, LegalDocType.privacy),
              child: Text(context.tr('login_privacy'), style: linkStyle),
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

class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = context.locale.languageCode == 'en';

    return GestureDetector(
      onTap: () {
        final newCode = isEn ? 'tr' : 'en';
        context.setLocale(Locale(newCode));
        ref.read(languageCodeProvider.notifier).setLanguage(newCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: AppTextStyles.labelSmall.copyWith(
                color: isEn ? AppColors.accentGlow : AppColors.textTertiary,
                fontWeight: isEn ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '|',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Text(
              'TR',
              style: AppTextStyles.labelSmall.copyWith(
                color: !isEn ? AppColors.accentGlow : AppColors.textTertiary,
                fontWeight: !isEn ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Email auth bottom sheet ──────────────────────────────────────────────────

class _EmailAuthSheet extends ConsumerStatefulWidget {
  const _EmailAuthSheet();

  @override
  ConsumerState<_EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends ConsumerState<_EmailAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _localiseError(BuildContext context, String key) {
    const keys = {
      'auth_err_rate_limit',
      'auth_err_email_exists',
      'auth_err_invalid_credentials',
      'auth_err_weak_password',
    };
    return keys.contains(key) ? context.tr(key) : key;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _errorMessage = null; _loading = true; });

    try {
      if (_isSignUp) {
        final needsConfirmation = await ref
            .read(authControllerProvider.notifier)
            .signUpWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
        if (!mounted) return;
        final authState = ref.read(authControllerProvider);
        if (authState.hasError) {
          setState(() => _errorMessage = _localiseError(context, authState.error.toString()));
        } else if (needsConfirmation) {
          final email = _emailCtrl.text.trim();
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.go('/confirm-email', extra: email);
        } else {
          // Signed in immediately — pop the sheet so GoRouter's redirect
          // doesn't leave a blocking transparent overlay on the home screen.
          Navigator.of(context).pop();
        }
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
        if (!mounted) return;
        final authState = ref.read(authControllerProvider);
        if (authState.hasError) {
          setState(() => _errorMessage = _localiseError(context, authState.error.toString()));
        } else {
          // Pop explicitly before GoRouter redirects — an un-dismissed modal
          // bottom sheet can leave a transparent overlay that blocks all touches
          // on the home screen, making it appear frozen.
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1223),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign In / Sign Up toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _Tab(
                    label: context.tr('login_email_tab_signin'),
                    selected: !_isSignUp,
                    onTap: () => setState(() { _isSignUp = false; _errorMessage = null; }),
                  ),
                  _Tab(
                    label: context.tr('login_email_tab_signup'),
                    selected: _isSignUp,
                    onTap: () => setState(() { _isSignUp = true; _errorMessage = null; }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Name field — sign-up only
            if (_isSignUp) ...[
              TextFormField(
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                style: AppTextStyles.bodyMedium,
                decoration: _inputDecoration(
                  context.tr('login_name_field'),
                  context.tr('login_name_hint'),
                  Icons.person_outline,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.tr('login_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            // Email field
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              style: AppTextStyles.bodyMedium,
              decoration: _inputDecoration(
                context.tr('login_email_field'),
                context.tr('login_email_hint'),
                Icons.email_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty || !v.contains('@')) {
                  return context.tr('login_email_invalid');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Password field
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              autofillHints: _isSignUp
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              style: AppTextStyles.bodyMedium,
              decoration: _inputDecoration(
                context.tr('login_password_field'),
                context.tr('login_password_hint'),
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return context.tr('login_password_short');
                }
                return null;
              },
            ),
            if (_isSignUp) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                autofillHints: const [AutofillHints.newPassword],
                style: AppTextStyles.bodyMedium,
                decoration: _inputDecoration(
                  context.tr('login_confirm_password'),
                  context.tr('login_confirm_password_hint'),
                  Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return context.tr('login_passwords_mismatch');
                  }
                  return null;
                },
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGlow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        _isSignUp
                            ? context.tr('login_signup_btn')
                            : context.tr('login_signin_btn'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
      labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accentGlow.withValues(alpha: 0.6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentGlow.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: AppColors.accentGlow.withValues(alpha: 0.4))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: selected ? AppColors.accentGlow : AppColors.textTertiary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Cosmic login background ─────────────────────────────────────────────────

class _LoginBackground extends StatefulWidget {
  final Widget child;
  const _LoginBackground({required this.child});

  @override
  State<_LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<_LoginBackground>
    with TickerProviderStateMixin {
  late final AnimationController _driftController;
  late final AnimationController _twinkleController;
  late final AnimationController _shootingController;
  late final List<_Star> _stars;
  _ShootingStar _shootingStar = const _ShootingStar(
    startX: 0.3, startY: 0.1, angle: 0.8, length: 0.18,
  );
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _shootingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _stars = List.generate(80, (_) => _Star.random(_rng));
    _scheduleShootingStar();
  }

  void _scheduleShootingStar() {
    Future.delayed(Duration(seconds: 5 + _rng.nextInt(6)), () {
      if (!mounted) return;
      // Update without setState — AnimatedBuilder reads the field on each frame.
      _shootingStar = _ShootingStar.random(_rng);
      _shootingController.forward(from: 0).then((_) => _scheduleShootingStar());
    });
  }

  @override
  void dispose() {
    _driftController.dispose();
    _twinkleController.dispose();
    _shootingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nebula blobs + background gradient — static, cached by RepaintBoundary.
        RepaintBoundary(
          child: CustomPaint(painter: _NebulaPainter()),
        ),
        // Star field — repaints every frame via two controllers.
        AnimatedBuilder(
          animation: Listenable.merge([_driftController, _twinkleController]),
          builder: (_, __) => CustomPaint(
            painter: _StarFieldPainter(
              stars: _stars,
              drift: _driftController.value,
              twinkle: _twinkleController.value,
            ),
          ),
        ),
        // Shooting star — only animates when the controller is running.
        AnimatedBuilder(
          animation: _shootingController,
          builder: (_, __) => CustomPaint(
            painter: _ShootingStarPainter(
              star: _shootingStar,
              progress: _shootingController.value,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Star {
  final double x, y, size, speed, phase, twinkleRate;
  final Color color;

  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.twinkleRate,
    required this.color,
  });

  static const _palette = [
    Colors.white,
    Colors.white,
    Colors.white,
    Color(0xFFB8B0FF), // soft lavender
    Color(0xFF90BBFF), // pale blue
    Color(0xFFFFEDD8), // warm white
  ];

  factory _Star.random(Random rng) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.2 + 0.3,
        speed: rng.nextDouble() * 0.015 + 0.003,
        phase: rng.nextDouble(),
        twinkleRate: rng.nextDouble() * 2.5 + 1.5,
        color: _palette[rng.nextInt(_palette.length)],
      );
}

class _ShootingStar {
  final double startX, startY, angle, length;

  const _ShootingStar({
    required this.startX,
    required this.startY,
    required this.angle,
    required this.length,
  });

  factory _ShootingStar.random(Random rng) => _ShootingStar(
        startX: 0.05 + rng.nextDouble() * 0.55,
        startY: 0.03 + rng.nextDouble() * 0.22,
        angle: pi / 6 + rng.nextDouble() * (pi / 5),
        length: 0.14 + rng.nextDouble() * 0.10,
      );
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark background gradient.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1026), Color(0xFF000000)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Deep purple — upper left.
    _blob(canvas, size, cx: -0.05, cy: 0.10, r: 0.65,
        color: const Color(0xFF2D1B69), opacity: 0.50);
    // Indigo — upper right.
    _blob(canvas, size, cx: 1.05, cy: 0.22, r: 0.60,
        color: const Color(0xFF1A1060), opacity: 0.42);
    // Violet glow — centre, behind the logo.
    _blob(canvas, size, cx: 0.50, cy: 0.30, r: 0.42,
        color: const Color(0xFF7B68EE), opacity: 0.10);
    // Dark magenta — bottom.
    _blob(canvas, size, cx: 0.50, cy: 1.05, r: 0.72,
        color: const Color(0xFF4A0E5E), opacity: 0.38);
    // Cool blue — mid right.
    _blob(canvas, size, cx: 0.90, cy: 0.62, r: 0.38,
        color: const Color(0xFF0D2B5E), opacity: 0.28);
  }

  void _blob(Canvas canvas, Size size, {
    required double cx, required double cy, required double r,
    required Color color, required double opacity,
  }) {
    final center = Offset(cx * size.width, cy * size.height);
    final radius = r * size.width;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter old) => false;
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double drift;
  final double twinkle;

  const _StarFieldPainter({
    required this.stars,
    required this.drift,
    required this.twinkle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Slow upward drift, wrapping at top.
      final y = ((star.y - drift * star.speed * 8) % 1.0 + 1.0) % 1.0;
      // Independent twinkling per star via phase offset.
      final phase = (twinkle * star.twinkleRate + star.phase) * 2 * pi;
      final opacity = 0.20 + (sin(phase) + 1) / 2 * 0.70;
      final center = Offset(star.x * size.width, y * size.height);

      // Larger stars get a soft bloom (two transparent halos).
      if (star.size > 1.6) {
        canvas.drawCircle(center, star.size * 4.0,
            Paint()..color = star.color.withValues(alpha: opacity * 0.05));
        canvas.drawCircle(center, star.size * 2.2,
            Paint()..color = star.color.withValues(alpha: opacity * 0.10));
      }

      canvas.drawCircle(
          center, star.size, Paint()..color = star.color.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) =>
      old.drift != drift || old.twinkle != twinkle;
}

class _ShootingStarPainter extends CustomPainter {
  final _ShootingStar star;
  final double progress;

  const _ShootingStarPainter({required this.star, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    // Fade in during first 15 %, fade out during last 28 %.
    final alpha = progress < 0.15
        ? progress / 0.15
        : progress > 0.72
            ? (1 - progress) / 0.28
            : 1.0;

    final hx = (star.startX + cos(star.angle) * progress * star.length) * size.width;
    final hy = (star.startY + sin(star.angle) * progress * star.length) * size.height;
    final tp = max(0.0, progress - 0.22);
    final tx = (star.startX + cos(star.angle) * tp * star.length) * size.width;
    final ty = (star.startY + sin(star.angle) * tp * star.length) * size.height;

    final head = Offset(hx, hy);
    final tail = Offset(tx, ty);

    // Gradient trail from transparent tail to bright head.
    if ((head - tail).distance > 1) {
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..shader = LinearGradient(colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: alpha * 0.85),
          ]).createShader(Rect.fromPoints(tail, head))
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    // Bright head dot + soft halo.
    canvas.drawCircle(head, 1.6,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.90));
    canvas.drawCircle(head, 3.2,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.18));
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter old) =>
      old.progress != progress || old.star != star;
}
