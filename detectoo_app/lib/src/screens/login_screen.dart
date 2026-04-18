import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../widgets/detectoo_button.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBranding(colorScheme),
                  const SizedBox(height: 48),
                  _buildFormCard(colorScheme, isLoading: isLoading),
                  const SizedBox(height: 24),
                  _buildSignUpLink(colorScheme),
                ],
              ),
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
    final emailOrUsername = _emailController.text.trim();
    final password = _passwordController.text;

    if (emailOrUsername.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    await ref.read(authProvider.notifier).signIn(
          emailOrUsername: emailOrUsername,
          password: password,
        );

    if (!mounted) return;

    final auth = ref.read(authProvider);
    auth.when(
      data: (user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      },
      error: (error, _) {
        final message =
            error is ApiException ? error.message : 'Login failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      loading: () {},
    );
  }

  /// Builds the app logo and welcome text with decorative leaves.
  Widget _buildBranding(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
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
            // Logo container
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
        const SizedBox(height: 24),
        Text(
          'Detectoo',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep your plants healthy',
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  /// Builds the form card containing email, password, and login button.
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
        children: [
          _buildEmailField(colorScheme),
          const SizedBox(height: 16),
          _buildPasswordField(colorScheme),
          const SizedBox(height: 24),
          DetectooButton(
            label: isLoading ? 'Logging In…' : 'Log In',
            height: 52,
            color: colorScheme.secondary,
            onPressed: isLoading ? () {} : _handleLogin,
          ),
        ],
      ),
    );
  }

  /// Builds the email input field.
  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
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
      ),
    );
  }

  /// Builds the password input field with visibility toggle.
  Widget _buildPasswordField(ColorScheme colorScheme) {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
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
      ),
    );
  }

  /// Builds the sign-up link text.
  Widget _buildSignUpLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to sign-up screen.
          },
          child: Text(
            'Sign Up',
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
