import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            const Color(0xFF00897B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                  color: Colors.white.withValues(alpha: 0.07),
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
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
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
                  user?.name ?? 'Plant Lover',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Member since ${user?.memberSince ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  /// Builds the plant stats row.
  Widget _buildStats(ColorScheme colorScheme) {
    // TODO: Replace with actual stats.
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                '7', 'Total Plants', Icons.yard_rounded, colorScheme)),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatCard(
                '4', 'Healthy', Icons.favorite_rounded, colorScheme,
                iconColor: colorScheme.secondary)),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatCard(
                '3', 'Recovering', Icons.healing_rounded, colorScheme,
                iconColor: const Color(0xFFFF6D00))),
      ],
    );
  }

  /// Builds a single stat card.
  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    ColorScheme colorScheme, {
    Color? iconColor,
  }) {
    return DetectooCard(
      bottomMargin: 0,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor ?? colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the preferences section with toggle switches.
  Widget _buildPreferences(ColorScheme colorScheme) {
    return DetectooCard(
      bottomMargin: 0,
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
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.secondary,
            activeTrackColor: colorScheme.secondaryContainer,
          ),
        ],
      ),
    );
  }

  /// Builds the account options list.
  Widget _buildAccountOptions(BuildContext context, ColorScheme colorScheme) {
    return DetectooCard(
      bottomMargin: 0,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildOptionTile(
            'Edit Profile',
            Icons.edit_outlined,
            colorScheme,
            onTap: () {
              // TODO: Navigate to edit profile.
            },
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildOptionTile(
            'Change Password',
            Icons.lock_outline_rounded,
            colorScheme,
            onTap: () {
              // TODO: Navigate to change password.
            },
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildOptionTile(
            'Help & Support',
            Icons.help_outline_rounded,
            colorScheme,
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
    IconData icon,
    ColorScheme colorScheme, {
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the logout button.
  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return DetectooButton(
      label: 'Log Out',
      icon: Icons.logout_rounded,
      outlined: true,
      color: const Color(0xFFC62828),
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
