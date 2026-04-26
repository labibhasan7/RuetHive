import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/screens/auth/signup_screen.dart';

import '../../core/constants.dart';
import '../../core/ui/spacing.dart';
import '../../core/state/auth_provider.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isAdminMode = false;
  bool _obscurePassword = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    )..forward();

    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

 Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isLoading = authState.status == AuthStatus.unknown;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── HEADER ─────────────────────────
                  Text(
                    _isAdminMode
                        ? 'Admin Login'
                        : 'Welcome Back 👋',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    _isAdminMode
                        ? 'Login as administrator'
                        : 'Login to continue to RUETHive',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ─── ROLE TOGGLE ─────────────────────
                  _buildRoleToggle(colorScheme),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── FORM CARD ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // EMAIL
                          TextFormField(
                            controller: _emailCtrl,
                            validator: AppValidators.email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon:
                              const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMD),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // PASSWORD
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            validator: (v) =>
                                AppValidators.requiredMinLength(
                                    v, 6,
                                    fieldName: 'Password'),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                              const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(() =>
                                _obscurePassword =
                                !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMD),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // ERROR
                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: Text(
                                authState.error!,
                                style: TextStyle(
                                    color: colorScheme.error),
                              ),
                            ),

                          // BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                              isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      AppConstants.radiusMD),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(_isAdminMode
                                  ? 'Login as Admin'
                                  : 'Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── SIGNUP ─────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.push(
                              context,
                        MaterialPageRoute(
                  builder: (_) => const SignupScreen(),
                  ),
                          ),    

                      child: const Text(
                          "Don't have an account? Sign Up"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Student / CR'),
            selected: !_isAdminMode,
            onSelected: (_) =>
                setState(() => _isAdminMode = false),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ChoiceChip(
            label: const Text('Admin'),
            selected: _isAdminMode,
            onSelected: (_) =>
                setState(() => _isAdminMode = true),
          ),
        ),
      ],
    );
  }
}