import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/api_providers.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../widgets/detectoo_button.dart';

enum _FieldStatus { idle, checking, available, taken }

/// Sign-up screen that creates a new Detectoo account.
///
/// Performs real-time username and email availability checks against the
/// backend (debounced at 500 ms) and shows a live password strength meter.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  _FieldStatus _usernameStatus = _FieldStatus.idle;
  _FieldStatus _emailStatus = _FieldStatus.idle;
  int _passwordStrength = 0; // 0–4

  Timer? _usernameDebounce;
  Timer? _emailDebounce;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _emailDebounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Debounced checks ──────────────────────────────────────────────────────

  void _onUsernameChanged() {
    final value = _usernameController.text.trim();
    _usernameDebounce?.cancel();
    if (value.length < 2 || !RegExp(r'^[a-z0-9]+$').hasMatch(value)) {
      if (_usernameStatus != _FieldStatus.idle) {
        setState(() => _usernameStatus = _FieldStatus.idle);
      }
      return;
    }
    setState(() => _usernameStatus = _FieldStatus.checking);
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final available = await ref
            .read(authRepositoryProvider)
            .isUsernameAvailable(value);
        if (!mounted) return;
        setState(() => _usernameStatus =
            available ? _FieldStatus.available : _FieldStatus.taken);
      } catch (_) {
        if (mounted) setState(() => _usernameStatus = _FieldStatus.idle);
      }
    });
  }

  void _onEmailChanged() {
    final value = _emailController.text.trim();
    _emailDebounce?.cancel();
    if (!_isValidEmail(value)) {
      if (_emailStatus != _FieldStatus.idle) {
        setState(() => _emailStatus = _FieldStatus.idle);
      }
      return;
    }
    setState(() => _emailStatus = _FieldStatus.checking);
    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final available =
            await ref.read(authRepositoryProvider).isEmailAvailable(value);
        if (!mounted) return;
        setState(() =>
            _emailStatus = available ? _FieldStatus.available : _FieldStatus.taken);
      } catch (_) {
        if (mounted) setState(() => _emailStatus = _FieldStatus.idle);
      }
    });
  }

  void _onPasswordChanged() {
    setState(() => _passwordStrength = _calcStrength(_passwordController.text));
  }

  // ── Password strength ─────────────────────────────────────────────────────

  static int _calcStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) score++;
    return score;
  }

  static const _strengthLabels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
  static const _strengthColors = [
    Colors.transparent,
    Color(0xFFE53935), // red
    Color(0xFFFB8C00), // orange
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // green
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _isValidEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  Widget? _statusSuffix(_FieldStatus status, ColorScheme cs) {
    switch (status) {
      case _FieldStatus.checking:
        return Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.primary,
            ),
          ),
        );
      case _FieldStatus.available:
        return Icon(Icons.check_circle_outline_rounded,
            color: const Color(0xFF43A047), size: 22);
      case _FieldStatus.taken:
        return Icon(Icons.cancel_outlined,
            color: cs.error, size: 22);
      case _FieldStatus.idle:
        return null;
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_usernameStatus == _FieldStatus.taken) return;
    if (_emailStatus == _FieldStatus.taken) return;

    await ref.read(authProvider.notifier).signUp(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    ref.read(authProvider).when(
      data: (user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      },
      error: (error, _) {
        final message =
            error is ApiException ? error.message : 'Sign-up failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      loading: () {},
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authProvider).isLoading;

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
                    _buildHeader(colorScheme),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child:
                          _buildFormCard(colorScheme, isLoading: isLoading),
                    ),
                    const SizedBox(height: 24),
                    _buildLoginLink(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    const Color(0xFF00897B),
                  ],
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
                Icons.local_florist_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Create Account',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join Detectoo and keep your plants healthy',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ColorScheme colorScheme, {required bool isLoading}) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            colorScheme: colorScheme,
            controller: _nameController,
            label: 'Full Name',
            hint: 'Jane Smith',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Name is required.';
              if (s.length < 2) return 'Name must be at least 2 characters.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // ── Username ──────────────────────────────────────────────────────
          _buildTextField(
            colorScheme: colorScheme,
            controller: _usernameController,
            label: 'Username',
            hint: 'janesmith',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            suffix: _statusSuffix(_usernameStatus, colorScheme),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Username is required.';
              if (s.length < 2) return 'Username must be at least 2 characters.';
              if (!RegExp(r'^[a-z0-9]+$').hasMatch(s)) {
                return 'Only lowercase letters and digits.';
              }
              if (_usernameStatus == _FieldStatus.taken) {
                return 'Username already taken.';
              }
              return null;
            },
          ),
          if (_usernameStatus == _FieldStatus.available)
            _buildAvailableHint('Username is available'),
          if (_usernameStatus == _FieldStatus.taken)
            _buildTakenHint('Username already taken', colorScheme),
          const SizedBox(height: 16),
          // ── Email ─────────────────────────────────────────────────────────
          _buildTextField(
            colorScheme: colorScheme,
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            suffix: _statusSuffix(_emailStatus, colorScheme),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Email is required.';
              if (!_isValidEmail(s)) return 'Enter a valid email address.';
              if (_emailStatus == _FieldStatus.taken) {
                return 'Email already registered.';
              }
              return null;
            },
          ),
          if (_emailStatus == _FieldStatus.available)
            _buildAvailableHint('Email is available'),
          if (_emailStatus == _FieldStatus.taken)
            _buildTakenHint('Email already registered', colorScheme),
          const SizedBox(height: 16),
          // ── Password ──────────────────────────────────────────────────────
          _buildPasswordField(
            colorScheme: colorScheme,
            controller: _passwordController,
            label: 'Password',
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if ((v ?? '').length < 8) {
                return 'Password must be at least 8 characters.';
              }
              return null;
            },
          ),
          if (_passwordStrength > 0) ...[
            const SizedBox(height: 8),
            _buildStrengthMeter(colorScheme),
          ],
          const SizedBox(height: 16),
          _buildPasswordField(
            colorScheme: colorScheme,
            controller: _confirmController,
            label: 'Confirm Password',
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          DetectooButton(
            label: isLoading ? 'Creating Account…' : 'Sign Up',
            height: 52,
            color: colorScheme.secondary,
            onPressed: isLoading ? () {} : _handleSignUp,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableHint(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF43A047),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTakenHint(String message, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: cs.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStrengthMeter(ColorScheme colorScheme) {
    final color = _strengthColors[_passwordStrength];
    final label = _strengthLabels[_passwordStrength];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < _passwordStrength;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled
                      ? color
                      : colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ColorScheme colorScheme,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool autocorrect = true,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: colorScheme.primaryContainer.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required ColorScheme colorScheme,
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: colorScheme.primaryContainer.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoginLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.login),
          child: Text(
            'Log In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
