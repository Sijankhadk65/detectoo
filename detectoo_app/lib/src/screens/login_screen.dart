import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/eyebrow_label.dart';

/// Login screen for the Detectoo application.
///
/// Allows users to authenticate before accessing the app's features.
/// Displays app branding, email/password fields, and a sign-up link.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBranding(),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: _buildFormCard(isLoading: isLoading),
                  ),
                  const SizedBox(height: 24),
                  Center(child: _buildSignUpLink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles the login action by authenticating against the backend
  /// and navigating home on success.
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref
        .read(authProvider.notifier)
        .signIn(email: email, password: password);

    if (!mounted) return;

    final auth = ref.read(authProvider);
    auth.when(
      data: (user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      },
      error: (error, _) {
        final message = error is ApiException ? error.message : 'Login failed.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      loading: () {},
    );
  }

  /// Builds the app logo lockup and welcome header.
  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DetectooColors.green600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'detect',
                    style: DetectooText.h2.copyWith(
                      color: DetectooColors.green900,
                    ),
                  ),
                  TextSpan(
                    text: 'oo',
                    style: DetectooText.h2.copyWith(
                      color: DetectooColors.green500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const EyebrowLabel('THE DIGITAL CURATOR'),
        const SizedBox(height: 10),
        Text('Welcome back,\nPlant Parent.', style: DetectooText.h1),
        const SizedBox(height: 10),
        Text(
          'Sign in to continue caring for your specimens.',
          style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
        ),
      ],
    );
  }

  /// Builds the form card containing email, password, and login button.
  Widget _buildFormCard({required bool isLoading}) {
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 28),
        DetectooButton(
          label: isLoading ? 'Logging in…' : 'Log In',
          onPressed: isLoading ? null : _handleLogin,
        ),
      ],
    );
  }

  /// Builds the email input field with format validation.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: DetectooText.body,
      validator: (value) {
        final trimmed = (value ?? '').trim();
        if (trimmed.isEmpty) return 'Email is required.';
        if (!_isValidEmail(trimmed)) return 'Enter a valid email address.';
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.mail_outline_rounded),
      ),
    );
  }

  /// Builds the password input field with visibility toggle.
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: DetectooText.body,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: DetectooColors.textMuted,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  /// Builds the sign-up link text.
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: DetectooText.small),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.signUp),
          child: Text(
            'Sign Up',
            style: DetectooText.small.copyWith(
              color: DetectooColors.terracotta,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
