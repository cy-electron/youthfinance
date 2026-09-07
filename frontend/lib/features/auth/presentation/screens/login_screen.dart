import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youthfinance/features/auth/data/auth_models.dart';
import 'package:youthfinance/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // ------------------------------------------------------------
  // App colors — emerald + cream, premium/quiet-luxury palette
  // Matches SignupScreen.
  // ------------------------------------------------------------

  static const Color _background = Color(0xFFFAF7F0); // warm cream
  static const Color _cardColor = Color(0xFFFFFFFF);

  static const Color _emerald = Color(0xFF0F5C3F); // deep emerald
  static const Color _emeraldDark = Color(0xFF0B4630);

  static const Color _textPrimary = Color(0xFF1C1B17);
  static const Color _textSecondary = Color(0xFF7A7566);

  static const Color _border = Color(0xFFE7E2D4);
  static const Color _errorColor = Color(0xFFB3453D);

  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<UserModel?>>(
      authProvider,
      (previous, next) {
        if (!mounted) return;

        next.when(
          data: (user) {
            if (user != null) {
              context.go('/dashboard');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Login failed. Please check your email and password.',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: _errorColor,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Validators
  // ------------------------------------------------------------

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
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }

    return null;
  }

  // ------------------------------------------------------------
  // Login
  // ------------------------------------------------------------

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );
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
  // Brand mark — same monogram as SignupScreen, for consistency
  // across the auth flow.
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
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                  'Welcome back',
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
                  'Sign in to continue.',
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
                      // Email
                      // ------------------------------------------------

                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
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
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                        ),
                        validator: _validatePassword,
                        onFieldSubmitted: (_) {
                          if (!isLoading) {
                            _login();
                          }
                        },
                        decoration: _inputDecoration(
                          label: 'Password',
                          hintText: 'Enter your password',
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

                      // ------------------------------------------------
                      // Forgot password
                      // ------------------------------------------------

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Password recovery will be available soon.',
                                      ),
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: _emeraldDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ------------------------------------------------
                      // Sign In
                      // ------------------------------------------------

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,

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

                            child: isLoading
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign in',
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
                // Signup
                // --------------------------------------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.go('/signup');
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: _emeraldDark,
                      ),
                      child: const Text(
                        'Create account',
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