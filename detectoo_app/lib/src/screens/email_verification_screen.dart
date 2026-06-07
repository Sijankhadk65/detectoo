import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/eyebrow_label.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
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
    return Scaffold(
      backgroundColor: DetectooColors.canvasCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(height: 28),
                  _buildCard(),
                  const SizedBox(height: 20),
                  _buildSkipLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: DetectooColors.green600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.mark_email_unread_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const EyebrowLabel('ONE MORE STEP'),
        const SizedBox(height: 8),
        Text(
          'Check your email.',
          textAlign: TextAlign.center,
          style: DetectooText.h1,
        ),
      ],
    );
  }

  Widget _buildCard() {
    return DetectooCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Email chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: DetectooColors.green100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail_outline_rounded,
                  size: 18,
                  color: DetectooColors.green700,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _userEmail,
                    style: DetectooText.small.copyWith(
                      color: DetectooColors.green700,
                      fontWeight: FontWeight.w700,
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
            style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: DetectooColors.green050,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: DetectooColors.green500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Verification email sent!',
                    style: DetectooText.small.copyWith(
                      color: DetectooColors.green600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          DetectooButton(label: 'Continue to App', onPressed: _continue),
          const SizedBox(height: 12),
          DetectooButton.ghost(
            label: _isSending
                ? 'Sending…'
                : (_cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend Email'),
            onPressed: (_isSending || _cooldown > 0) ? null : _resend,
          ),
        ],
      ),
    );
  }

  Widget _buildSkipLink() {
    return GestureDetector(
      onTap: _continue,
      child: Text(
        'Skip for now',
        style: DetectooText.small.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
