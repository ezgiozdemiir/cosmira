import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/web_utils_stub.dart'
    if (dart.library.js_interop) '../../../../core/utils/web_utils_html.dart';
import '../providers/auth_provider.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String? password;
  const ConfirmEmailScreen({super.key, required this.email, this.password});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  bool _resending = false;
  bool _resent = false;
  bool _checking = false;
  Timer? _pollTimer;
  String? _debugError;
  late final String _storageKey;

  @override
  void initState() {
    super.initState();
    final projectRef = Uri.parse(Env.supabaseUrl).host.split('.').first;
    _storageKey = 'sb-$projectRef-auth-token';

    if (kIsWeb) {
      final code = getUrlQueryCode();
      if (code != null) {
        clearUrlCode();
        _exchangeCode(code);
        return;
      }
    }

    // Poll every 3 s: wait for another tab to confirm and write a session to
    // localStorage, then reload so Supabase.initialize() restores it cleanly.
    // (recoverSession() can't be used here because supabase_flutter stores the
    // session wrapped as {"currentSession":{...},"expiresAt":N}, which doesn't
    // match the raw Session format that recoverSession() expects.)
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) { timer.cancel(); return; }

      if (kIsWeb) {
        final sessionStr = readLocalStorage(_storageKey);
        if (sessionStr != null) {
          timer.cancel();
          reloadPage();
        }
        return;
      }

      // Mobile: session is in the current process.
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        timer.cancel();
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _exchangeCode(String code) async {
    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
    } catch (e) {
      // The verifier might already be gone because _handleInitialUri() inside
      // Supabase.initialize() ran the same exchange concurrently. Poll for up
      // to 5 s to let that in-flight request finish and set currentUser.
      for (int i = 0; i < 10; i++) {
        if (!mounted) return;
        if (Supabase.instance.client.auth.currentUser != null) {
          context.go('/');
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (mounted) setState(() => _debugError = e.toString());
    }
  }

  Future<void> _resend() async {
    setState(() { _resending = true; _resent = false; });
    await ref.read(authControllerProvider.notifier).resendConfirmationEmail(widget.email);
    if (mounted) setState(() { _resending = false; _resent = true; });
  }

  Future<void> _checkAndContinue() async {
    setState(() => _checking = true);

    if (kIsWeb) {
      // If the confirmation link opened in this same tab there may be a code
      // in the URL that wasn't processed yet (e.g. user pressed the button
      // before the async exchange completed).
      final code = getUrlQueryCode();
      if (code != null) {
        clearUrlCode();
        await _exchangeCode(code);
        if (!mounted) return;
        if (Supabase.instance.client.auth.currentUser != null) {
          context.go('/');
          return;
        }
      }

      // If another tab confirmed and wrote a session to localStorage, reload
      // so Supabase.initialize() can restore it properly.
      if (readLocalStorage(_storageKey) != null) {
        reloadPage();
        return;
      }

      setState(() => _checking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('confirm_email_not_yet')),
            backgroundColor: AppColors.softIndigo,
          ),
        );
      }
      return;
    }

    // Mobile: no session exists yet, so refreshSession() can't work. Instead,
    // try signing in — if the email was confirmed on any device, this succeeds
    // and the auth state listener above navigates to home automatically.
    final password = widget.password;
    if (password != null && password.isNotEmpty) {
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: widget.email,
          password: password,
        );
        // Auth state listener handles navigation; nothing more to do here.
        return;
      } on AuthApiException catch (e) {
        if (!mounted) return;
        setState(() => _checking = false);
        final isNotConfirmed = e.code == 'email_not_confirmed' ||
            (e.message.toLowerCase().contains('not confirmed'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNotConfirmed
                ? context.tr('confirm_email_not_yet')
                : e.message),
            backgroundColor: AppColors.softIndigo,
          ),
        );
        return;
      } catch (_) {}
    }

    // Fallback: check if a session already exists in this process.
    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      context.go('/');
    } else {
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('confirm_email_not_yet')),
          backgroundColor: AppColors.softIndigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same-tab auth events (e.g. if the link opens in this tab).
    ref.listen(authStateProvider, (_, next) {
      next.whenData((state) {
        if (state.session != null && mounted) context.go('/');
      });
    });

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGlow.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.accentGlow.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.accentGlow,
                      size: 38,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 36),
                Text(
                  context.tr('confirm_email_title'),
                  style: AppTextStyles.displayMedium.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                const SizedBox(height: 16),
                Text(
                  context.tr('confirm_email_subtitle'),
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 250.ms, duration: 500.ms),
                const SizedBox(height: 6),
                Text(
                  widget.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentGlow,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: 20),
                Text(
                  context.tr('confirm_email_instructions'),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 380.ms, duration: 500.ms),
                if (_debugError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.withValues(alpha: 0.15),
                    child: Text(
                      'DEBUG: $_debugError\n\n'
                      'Verifier [raw]: ${readLocalStorage("supabase.auth.token-code-verifier") != null ? "YES" : "NO"}\n'
                      'Verifier [flutter.]: ${readLocalStorage("flutter.supabase.auth.token-code-verifier") != null ? "YES" : "NO"}\n'
                      'currentUser: ${Supabase.instance.client.auth.currentUser?.id ?? "null"}\n\n'
                      'ALL localStorage keys:\n${dumpLocalStorageKeys()}',
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                ],
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: _checking ? null : _checkAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGlow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('confirm_email_continue'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ).animate().fadeIn(delay: 430.ms, duration: 500.ms),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _resending ? null : _resend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGlow,
                    side: BorderSide(
                      color: AppColors.accentGlow.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _resending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentGlow,
                          ),
                        )
                      : Text(
                          _resent
                              ? context.tr('confirm_email_resent')
                              : context.tr('confirm_email_resend'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 12),
                Text(
                  context.tr('confirm_email_spam'),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 560.ms, duration: 500.ms),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    context.tr('confirm_email_back'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ).animate().fadeIn(delay: 620.ms, duration: 500.ms),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
