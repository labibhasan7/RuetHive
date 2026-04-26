import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/ui/spacing.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/role_provider.dart';
import '../../models/app_user.dart';
import '../../core/utils/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── CONTROLLERS ─────────────────────────
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();

  bool _isAdmin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _rollCtrl.dispose();
    _deptCtrl.dispose();
    _batchCtrl.dispose();
    _sectionCtrl.dispose();
    super.dispose();
  }

  // ─── SIGNUP ─────────────────────────────
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final role = _isAdmin ? UserRole.admin : UserRole.student;

    final user = AppUser(
      uid: '',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      studentId: _isAdmin ? '' : _rollCtrl.text.trim(),
      department: _isAdmin ? '' : _deptCtrl.text.trim(),
      batch: _isAdmin ? '' : _batchCtrl.text.trim(),
      section: _isAdmin ? '' : _sectionCtrl.text.trim(),
      role: role,
      memberSince: DateTime.now().toString(),
    );

    await ref
        .read(authProvider.notifier)
        .signup(user, _passwordCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isLoading = authState.status == AuthStatus.unknown;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ─── HEADER ─────────────────────────
                Text(
                  'Create your account 🚀',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Join RUETHive and get started',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ─── ROLE TOGGLE ───────────────────
                _buildRoleToggle(colorScheme),

                const SizedBox(height: AppSpacing.lg),

                // ─── FORM CARD ─────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius:
                    BorderRadius.circular(AppConstants.radiusLG),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // NAME
                        TextFormField(
                          controller: _nameCtrl,
                          validator: AppValidators.required,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // EMAIL
                        TextFormField(
                          controller: _emailCtrl,
                          validator: AppValidators.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // STUDENT FIELDS
                        if (!_isAdmin) ...[
                          TextFormField(
                            controller: _rollCtrl,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                              labelText: 'Student ID',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          TextFormField(
                            controller: _deptCtrl,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                              labelText: 'Department (CSE, EEE...)',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          TextFormField(
                            controller: _batchCtrl,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                              labelText: 'Batch (e.g. 23 Series)',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          TextFormField(
                            controller: _sectionCtrl,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                              labelText: 'Section (A, B...)',
                              prefixIcon: Icon(Icons.group_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

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
                            isLoading ? null : _signup,
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
                                : Text(_isAdmin
                                ? 'Create Admin Account'
                                : 'Create Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ─── LOGIN NAV ─────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        "Already have an account? Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── ROLE TOGGLE ─────────────────────────
  Widget _buildRoleToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Student / CR'),
            selected: !_isAdmin,
            onSelected: (_) =>
                setState(() => _isAdmin = false),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ChoiceChip(
            label: const Text('Admin'),
            selected: _isAdmin,
            onSelected: (_) =>
                setState(() => _isAdmin = true),
          ),
        ),
      ],
    );
  }
}