import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

/// Notifier that manages the authenticated user state.
///
/// Holds the current [User] or `null` when no one is logged in.
class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  /// Signs in by creating a new user from the provided credentials.
  void signIn({required String name, required String email}) {
    final now = DateTime.now();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final memberSince = '${monthNames[now.month - 1]} ${now.year}';

    state = User((b) => b
      ..name = name
      ..email = email
      ..memberSince = memberSince);
  }

  /// Signs out the current user.
  void signOut() {
    state = null;
  }
}

/// Provides the [AuthNotifier] and exposes the current [User] state.
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
