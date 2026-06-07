import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';

/// A warning banner shown when the signed-in user has not yet verified
/// their email address.
///
/// Self-hides (renders nothing) when the user is verified or when
/// verification status is unknown (e.g. an older cached session), so
/// screens can include it unconditionally. Offers a "Resend" action
/// (with a cooldown) and an "I've verified" action that re-checks the
/// user's status after they click the link in their inbox.
class VerificationBanner extends ConsumerStatefulWidget {
  const VerificationBanner({super.key});

  @override
  ConsumerState<VerificationBanner> createState() => _VerificationBannerState();
}

class _VerificationBannerState extends ConsumerState<VerificationBanner> {
  /// Cooldown in seconds after tapping "Resend".
  static const _cooldownSeconds = 60;

  bool _isSending = false;
  bool _isRefreshing = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_isSending || _cooldown > 0) return;
    setState(() => _isSending = true);

    try {
      await ref.read(authProvider.notifier).resendVerification();
      if (!mounted) return;
      setState(() => _cooldown = _cooldownSeconds);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
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

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      await ref.read(authProvider.notifier).refreshUser();
      if (!mounted) return;
      // If still unverified after refreshing, let the user know nothing changed.
      final verified =
          ref.read(authProvider).valueOrNull?.isEmailVerified ?? false;
      if (!verified) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                "Still not verified. Open the link in your email first.",
              ),
            ),
          );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not refresh. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    // Only warn when we explicitly know the email is unverified.
    if (user == null || user.isEmailVerified != false) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "We sent a verification link to ${user.email}. "
            'Open it to activate your account.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: (_isSending || _cooldown > 0) ? null : _resend,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: _isSending
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      )
                    : Text(
                        _cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: _isRefreshing ? null : _refresh,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: _isRefreshing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : const Text(
                        "I've verified",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
