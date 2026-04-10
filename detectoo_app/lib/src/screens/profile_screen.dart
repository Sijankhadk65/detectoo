import 'package:flutter/material.dart';

import '../routes.dart';

/// User profile screen for the Detectoo application.
///
/// Displays user avatar, name, email, plant stats,
/// app preferences, and a logout option.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TODO: Replace with actual user preferences.
  bool _notificationsEnabled = true;
  bool _waterReminders = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme),
              const SizedBox(height: 24),
              _buildStats(colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('Preferences', Icons.tune_rounded, colorScheme),
              const SizedBox(height: 12),
              _buildPreferences(colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('Account', Icons.person_outline_rounded, colorScheme),
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

  /// Builds the profile header with avatar, name, and email.
  Widget _buildHeader(ColorScheme colorScheme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 44,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            // TODO: Replace with actual user name.
            'Plant Lover',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            // TODO: Replace with actual user email.
            'plantlover@example.com',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since Mar 2026',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the plant stats row.
  Widget _buildStats(ColorScheme colorScheme) {
    // TODO: Replace with actual stats.
    return Row(
      children: [
        Expanded(child: _buildStatCard('7', 'Total Plants', Icons.yard_rounded, colorScheme)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('4', 'Healthy', Icons.favorite_rounded, colorScheme)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('3', 'Recovering', Icons.healing_rounded, colorScheme)),
      ],
    );
  }

  /// Builds a single stat card.
  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
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

  /// Builds a section title row.
  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the preferences section with toggle switches.
  Widget _buildPreferences(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
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
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Builds the account options list.
  Widget _buildAccountOptions(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Implement actual logout logic.
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Log Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC62828),
          side: const BorderSide(color: Color(0xFFC62828), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
