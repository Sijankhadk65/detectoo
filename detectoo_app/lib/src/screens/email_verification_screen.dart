import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../widgets/detectoo_button.dart';

/// Shown immediately after sign-up to prompt the user to verify their email.
///
/// The actual verification happens when the user clicks the link in their
/// inbox — that hits the backend and updates [User.isEmailVerified]. The
/// user can tap "Continue" at any time to proceed to the home screen.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  /// Cooldown in seconds after tapping "Resend".
  static const _cooldownSeconds = 60;

  bool _isSending = false;
  bool _sent = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _userEmail {
    final user = ref.read(authProvider).valueOrNull;
    return user?.email ?? '';
  }

  Future<void> _resend() async {
    if (_isSending || _cooldown > 0) return;
    setState(() => _isSending = true);

    try {
      await ref.read(authProvider.notifier).resendVerification();
      if (!mounted) return;
      setState(() {
        _sent = true;
        _cooldown = _cooldownSeconds;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _cooldown--;
          if (_cooldown <= 0) t.cancel();
        });
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend email. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _continue() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                colorScheme.surface.withValues(alpha: 0.85),
                colorScheme.surface,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(colorScheme),
                    const SizedBox(height: 32),
                    _buildCard(colorScheme),
                    const SizedBox(height: 24),
                    _buildSkipLink(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_unread_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Check Your Email',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'One more step to activate your account',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'We sent a verification link to your email address. '
            'Open it and click the link to verify your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Verification email sent!',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          DetectooButton(
            label: 'Continue to App',
            height: 52,
            onPressed: _continue,
          ),
          const SizedBox(height: 12),
          // Resend button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed:
                  (_isSending || _cooldown > 0) ? null : _resend,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Text(
                      _cooldown > 0
                          ? 'Resend in ${_cooldown}s'
                          : 'Resend Email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _cooldown > 0
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : colorScheme.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipLink(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _continue,
      child: Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
