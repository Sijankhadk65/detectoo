import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/icon_badge.dart';
import '../widgets/section_title.dart';

/// User profile screen for the Detectoo application.
///
/// Displays user avatar, name, email, plant stats,
/// app preferences, and a logout option.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // TODO: Replace with actual user preferences.
  bool _notificationsEnabled = true;
  bool _waterReminders = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme, user),
              const SizedBox(height: 24),
              _buildStats(colorScheme),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Preferences',
                icon: Icons.tune_rounded,
              ),
              const SizedBox(height: 12),
              _buildPreferences(colorScheme),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Account',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildAccountOptions(context, colorScheme),
              const SizedBox(height: 32),
              _buildLogoutButton(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile header with gradient background, avatar, name,
  /// and email.
  Widget _buildHeader(ColorScheme colorScheme, User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DetectooColors.surfaceDark, DetectooColors.surfaceDarkDeep],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: DetectooShadows.cardMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -20,
              right: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DetectooColors.green500.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DetectooColors.green300.withValues(alpha: 0.08),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DetectooColors.green300.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'Plant Parent',
                  style: DetectooText.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: DetectooText.small.copyWith(
                    color: DetectooColors.textOnDarkMuted,
                  ),
                ),
                if (user?.isEmailVerified != null) ...[
                  const SizedBox(height: 10),
                  _buildVerificationPill(user!.isEmailVerified!),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Member since ${user?.memberSince ?? ''}',
                    style: DetectooText.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the email-verification status pill shown in the dark header.
  ///
  /// Static when verified; tappable (to resend the verification email) when not.
  Widget _buildVerificationPill(bool verified) {
    final icon = verified
        ? Icons.verified_rounded
        : Icons.error_outline_rounded;
    final label = verified ? 'Email verified' : 'Email not verified · Resend';

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );

    if (verified) return pill;

    return GestureDetector(onTap: _resendVerification, child: pill);
  }

  /// Resends the verification email and surfaces the outcome via a snackbar.
  Future<void> _resendVerification() async {
    try {
      await ref.read(authProvider.notifier).resendVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend email. Try again.')),
      );
    }
  }

  /// Builds the plant stats row.
  Widget _buildStats(ColorScheme colorScheme) {
    // TODO: Replace with actual stats.
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '7',
            'Total Plants',
            Icons.spa_rounded,
            DetectooColors.green600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            '4',
            'Healthy',
            Icons.favorite_rounded,
            DetectooColors.green500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            '3',
            'Recovering',
            Icons.healing_rounded,
            DetectooColors.terracotta,
          ),
        ),
      ],
    );
  }

  /// Builds a single stat card.
  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return DetectooCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(value, style: DetectooText.h2),
          const SizedBox(height: 2),
          Text(label, style: DetectooText.small),
        ],
      ),
    );
  }

  /// Builds the preferences section with toggle switches.
  Widget _buildPreferences(ColorScheme colorScheme) {
    return DetectooCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildToggleTile(
            'Push Notifications',
            'Get alerts about your plants',
            Icons.notifications_outlined,
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            colorScheme,
          ),
          const Divider(height: 1, color: DetectooColors.borderSoft),
          _buildToggleTile(
            'Water Reminders',
            'Daily reminders to water your plants',
            Icons.water_drop_outlined,
            _waterReminders,
            (value) => setState(() => _waterReminders = value),
            colorScheme,
          ),
        ],
      ),
    );
  }

  /// Builds a single toggle tile for preferences.
  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconBadge(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DetectooText.bodyStrong),
                const SizedBox(height: 2),
                Text(subtitle, style: DetectooText.small),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: DetectooColors.green600,
          ),
        ],
      ),
    );
  }

  /// Builds the account options list.
  Widget _buildAccountOptions(BuildContext context, ColorScheme colorScheme) {
    return DetectooCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildOptionTile(
            'Edit Profile',
            Icons.edit_outlined,
            onTap: () {
              // TODO: Navigate to edit profile.
            },
          ),
          const Divider(height: 1, color: DetectooColors.borderSoft),
          _buildOptionTile(
            'Change Password',
            Icons.lock_outline_rounded,
            onTap: () {
              // TODO: Navigate to change password.
            },
          ),
          const Divider(height: 1, color: DetectooColors.borderSoft),
          _buildOptionTile(
            'Help & Support',
            Icons.help_outline_rounded,
            onTap: () {
              // TODO: Navigate to help screen.
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single tappable option tile.
  Widget _buildOptionTile(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconBadge(icon: icon),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: DetectooText.bodyStrong)),
            const Icon(
              Icons.chevron_right_rounded,
              color: DetectooColors.textFaint,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the logout button.
  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return DetectooButton.ghost(
      label: 'Log Out',
      icon: Icons.logout_rounded,
      color: DetectooColors.terracotta,
      onPressed: () async {
        await ref.read(authProvider.notifier).signOut();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      },
    );
  }
}
