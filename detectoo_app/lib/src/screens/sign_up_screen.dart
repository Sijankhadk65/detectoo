import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/eyebrow_label.dart';

/// Sign-up screen that creates a new Detectoo account.
///
/// On success the user is automatically logged in and sent to the home screen.
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

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  static bool _isValidEmail(String v) =>
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$').hasMatch(v);

  static String? _passwordStrengthError(String v) {
    final missing = <String>[];
    if (v.length < 8) missing.add('at least 8 characters');
    if (!RegExp(r'[A-Z]').hasMatch(v)) missing.add('an uppercase letter');
    if (!RegExp(r'[a-z]').hasMatch(v)) missing.add('a lowercase letter');
    if (!RegExp(r'[0-9]').hasMatch(v)) missing.add('a number');
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v)) {
      missing.add('a special character');
    }
    if (missing.isEmpty) return null;
    return 'Password must contain ${missing.join(', ')}.';
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authProvider.notifier)
        .signUp(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    ref
        .read(authProvider)
        .when(
          data: (user) {
            if (user != null) {
              Navigator.pushReplacementNamed(context, Routes.emailVerification);
            }
          },
          error: (error, _) {
            final message = error is ApiException
                ? error.message
                : 'Sign-up failed.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          loading: () {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: DetectooColors.canvasCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: _buildFormCard(isLoading: isLoading),
                  ),
                  const SizedBox(height: 24),
                  Center(child: _buildLoginLink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowLabel('THE DIGITAL CURATOR'),
        const SizedBox(height: 10),
        Text('Create your account.', style: DetectooText.h1),
        const SizedBox(height: 10),
        Text(
          'Join Detectoo and keep your specimens thriving.',
          style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildFormCard({required bool isLoading}) {
    return Column(
      children: [
        _buildTextField(
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
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'janesmith',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.visiblePassword,
          autocorrect: false,
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Username is required.';
            if (s.length < 2) return 'Username must be at least 2 characters.';
            if (!RegExp(r'^[a-z0-9]+$').hasMatch(s)) {
              return 'Only lowercase letters and digits.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _emailController,
          builder: (context, value, _) {
            final text = value.text.trim();
            final valid = _isValidEmail(text);
            return _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: text.isNotEmpty
                  ? Icon(
                      valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: valid
                          ? DetectooColors.green500
                          : DetectooColors.danger,
                      size: 20,
                    )
                  : null,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Email is required.';
                if (!_isValidEmail(s)) return 'Enter a valid email address.';
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _passwordController,
          label: 'Password',
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (v) => _passwordStrengthError(v ?? ''),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _passwordController,
          builder: (context, value, _) =>
              _buildPasswordStrengthIndicator(value.text),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _confirmController,
          label: 'Confirm Password',
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          validator: (v) {
            if (v != _passwordController.text) return 'Passwords do not match.';
            return null;
          },
        ),
        const SizedBox(height: 28),
        DetectooButton(
          label: isLoading ? 'Creating account…' : 'Sign Up',
          onPressed: isLoading ? null : _handleSignUp,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool autocorrect = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      validator: validator,
      style: DetectooText.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordField({
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
      style: DetectooText.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: DetectooColors.textMuted,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    final criteria = [
      ('8+ characters', password.length >= 8),
      ('Uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
      ('Lowercase letter', RegExp(r'[a-z]').hasMatch(password)),
      ('Number', RegExp(r'[0-9]').hasMatch(password)),
      (
        'Special character',
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password),
      ),
    ];

    final metCount = criteria.where((c) => c.$2).length;

    final (barColor, label) = switch (metCount) {
      1 => (DetectooColors.danger, 'Weak'),
      2 => (DetectooColors.warning, 'Fair'),
      3 => (DetectooColors.green400, 'Good'),
      4 => (DetectooColors.green500, 'Strong'),
      _ => (DetectooColors.green600, 'Very Strong'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            ...List.generate(
              5,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < metCount ? barColor : DetectooColors.green100,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: DetectooText.small.copyWith(
                color: barColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: criteria
              .map(
                (c) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      c.$2
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: c.$2
                          ? DetectooColors.green500
                          : DetectooColors.textFaint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c.$1,
                      style: DetectooText.small.copyWith(
                        color: c.$2
                            ? DetectooColors.green600
                            : DetectooColors.textFaint,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: DetectooText.small),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Log In',
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
