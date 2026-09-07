import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ------------------------------------------------------------
  // App colors — emerald + cream, premium/quiet-luxury palette
  // ------------------------------------------------------------

  static const Color _background = Color(0xFFFAF7F0); // warm cream
  static const Color _cardColor = Color(0xFFFFFFFF);

  static const Color _emerald = Color(0xFF0F5C3F); // deep emerald
  static const Color _emeraldDark = Color(0xFF0B4630);
  static const Color _emeraldSoft = Color(0xFFEFF3EC); // pale emerald tint

  static const Color _textPrimary = Color(0xFF1C1B17);
  static const Color _textSecondary = Color(0xFF7A7566);

  static const Color _border = Color(0xFFE7E2D4);
  static const Color _errorColor = Color(0xFFB3453D);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Validators
  // ------------------------------------------------------------

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name.';
    }

    if (name.length < 2) {
      return 'Please enter a valid name.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter a password.';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // ------------------------------------------------------------
  // Signup
  // ------------------------------------------------------------

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).register(
            fullName: fullName,
            email: email,
            password: password,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created. Please sign in.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _emeraldDark,
        ),
      );

      context.go('/login');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to create account. Please check your details.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // Input decoration
  // ------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,

      prefixIcon: Icon(
        icon,
        color: _textSecondary,
        size: 20,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: _background,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _emerald,
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.2),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.4),
      ),

      labelStyle: const TextStyle(
        color: _textSecondary,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),

      hintStyle: const TextStyle(
        color: Color(0xFFB6AF9C),
        fontSize: 14.5,
      ),

      errorStyle: const TextStyle(
        color: _errorColor,
        fontSize: 12,
      ),
    );
  }

  // ------------------------------------------------------------
  // Brand mark — restrained monogram instead of an illustrated
  // mascot, in keeping with a premium finance-app feel.
  // ------------------------------------------------------------

  Widget _buildBrandMark() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _emerald,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _emerald.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'YF',
          style: TextStyle(
            color: _background,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --------------------------------------------------
                // Brand mark
                // --------------------------------------------------

                Center(child: _buildBrandMark()),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // Heading
                // --------------------------------------------------

                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Set up your account to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // --------------------------------------------------
                // Form card
                // --------------------------------------------------

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C1B17).withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ------------------------------------------------
                      // Full Name
                      // ------------------------------------------------

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        validator: _validateName,
                        decoration: _inputDecoration(
                          label: 'Full name',
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // Email
                      // ------------------------------------------------

                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        validator: _validateEmail,
                        decoration: _inputDecoration(
                          label: 'Email',
                          hintText: 'you@example.com',
                          icon: Icons.mail_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // Password
                      // ------------------------------------------------

                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        validator: _validatePassword,
                        onChanged: (_) {
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _formKey.currentState?.validate();
                          }
                        },
                        decoration: _inputDecoration(
                          label: 'Password',
                          hintText: 'Create a password',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // Confirm Password
                      // ------------------------------------------------

                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_isLoading,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) {
                          if (!_isLoading) {
                            _signup();
                          }
                        },
                        decoration: _inputDecoration(
                          label: 'Confirm password',
                          hintText: 'Enter your password again',
                          icon: Icons.verified_user_outlined,
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirmPassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ------------------------------------------------
                      // Password requirement
                      // ------------------------------------------------

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _emeraldSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: _emerald,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Use at least 8 characters for a stronger password.',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // Create Account
                      // ------------------------------------------------

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _emerald,
                            foregroundColor: _background,
                            disabledBackgroundColor:
                                _emerald.withValues(alpha: 0.45),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isLoading
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        _background,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    key: ValueKey('button'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create account',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // Login
                // --------------------------------------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.go('/login');
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: _emeraldDark,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}