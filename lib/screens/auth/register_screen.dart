import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1 — Account & basic personal info
  final _step1Key = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  DateTime? _birthDate;

  // Username availability
  Timer? _usernameDebounce;
  bool _checkingUsername = false;
  bool? _usernameAvailable;

  // Step 2 — Optional physical info
  final _step2Key = GlobalKey<FormState>();
  String? _gender;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _activityLevel;
  String? _cookingSkillLevel;

  static const _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _activityOptions = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active',
  ];
  static const _skillOptions = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      setState(() {
        _usernameAvailable = null;
        _checkingUsername = false;
      });
      return;
    }
    setState(() => _checkingUsername = true);
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      bool? available;
      try {
        available =
            await context.read<AuthProvider>().isUsernameAvailable(trimmed);
      } catch (_) {
        available = null;
      }
      if (mounted && _usernameController.text.trim() == trimmed) {
        setState(() {
          _usernameAvailable = available;
          _checkingUsername = false;
        });
      }
    });
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (!_step1Key.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectDateOfBirth)),
      );
      return;
    }
    if (_usernameAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseChooseAvailableUsername)),
      );
      return;
    }
    _goToPage(1);
  }

  Future<void> _handleRegister() async {
    if (!_step2Key.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _phoneController.text.trim(),
      birthDate: _birthDate!,
      username: _usernameController.text.trim(),
      gender: _gender,
      heightCm: double.tryParse(_heightController.text),
      weightKg: double.tryParse(_weightController.text),
      activityLevel: _activityLevel,
      cookingSkillLevel: _cookingSkillLevel,
    );

    if (success && mounted) {
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      helpText: AppLocalizations.of(context)!.selectDateOfBirth,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (context.canPop())
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (context.canPop()) const SizedBox(width: 8),
                      Image.asset(
                        'assets/logo.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.register,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StepDot(
                        index: 1,
                        active: _currentPage == 0,
                        done: _currentPage > 0,
                        label: l10n.account,
                      ),
                      Expanded(
                        child: Divider(
                          color: _currentPage > 0
                              ? AppTheme.primaryColor
                              : AppTheme.neutralLightOf(context),
                          thickness: 2,
                        ),
                      ),
                      _StepDot(
                        index: 2,
                        active: _currentPage == 1,
                        done: false,
                        label: l10n.profile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(l10n, authProvider),
                  _buildStep2(l10n, authProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.accountInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
            ),
            const SizedBox(height: 20),

            // First & Last name side by side
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.firstName,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.lastName,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                prefixIcon: const Icon(Icons.alternate_email),
                suffixIcon: _checkingUsername
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      )
                    : _usernameAvailable == true
                        ? const Icon(Icons.check_circle,
                            color: AppTheme.primaryColor)
                        : _usernameAvailable == false
                            ? const Icon(Icons.cancel,
                                color: AppTheme.errorColor)
                            : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: _onUsernameChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.usernameRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.usernameTooShort;
                }
                if (_usernameAvailable == false) {
                  return l10n.usernameTaken;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterEmail;
                }
                if (!value.contains('@')) {
                  return l10n.pleaseEnterValidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.phoneNumberRequired;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 7) {
                  return l10n.invalidPhoneNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birth Date (mandatory)
            GestureDetector(
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${l10n.dateOfBirth} *',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  suffixIcon:
                      const Icon(Icons.calendar_today_outlined, size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _birthDate == null
                          ? AppTheme.neutralLightOf(context)
                          : AppTheme.primaryColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.day.toString().padLeft(2, '0')}/'
                          '${_birthDate!.month.toString().padLeft(2, '0')}/'
                          '${_birthDate!.year}'
                      : l10n.selectDateOfBirth,
                  style: TextStyle(
                    color: _birthDate != null
                        ? null
                        : AppTheme.textTertiaryOf(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterPassword;
                }
                if (value.length < 6) {
                  return l10n.passwordTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            GradientButton(
              text: l10n.next,
              onPressed: _nextPage,
              icon: Icons.arrow_forward,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.haveAccount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(AppLocalizations l10n, AuthProvider authProvider) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.personalInformation,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.helpsPersonalizeExperience,
              style: textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textTertiaryOf(context)),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: InputDecoration(
                labelText: l10n.gender,
                prefixIcon: const Icon(Icons.wc_outlined),
              ),
              items: _genderOptions.map((g) {
                final label = switch (g) {
                  'Male' => l10n.genderMale,
                  'Female' => l10n.genderFemale,
                  'Other' => l10n.genderOther,
                  'Prefer not to say' => l10n.genderPreferNotToSay,
                  _ => g,
                };
                return DropdownMenuItem(value: g, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}\.?\d{0,1}')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.height,
                      prefixIcon: const Icon(Icons.height),
                      suffixText: 'cm',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final v = double.tryParse(value);
                        if (v == null || v < 50 || v > 300) {
                          return l10n.invalid;
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}\.?\d{0,1}')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.weight,
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      suffixText: 'kg',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final v = double.tryParse(value);
                        if (v == null || v < 20 || v > 500) {
                          return l10n.invalid;
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _activityLevel,
              decoration: InputDecoration(
                labelText: l10n.activityLevel,
                prefixIcon: const Icon(Icons.directions_run_outlined),
              ),
              items: _activityOptions.map((a) {
                final label = switch (a) {
                  'Sedentary' => l10n.activitySedentary,
                  'Lightly Active' => l10n.activityLightlyActive,
                  'Moderately Active' => l10n.activityModeratelyActive,
                  'Very Active' => l10n.activityVeryActive,
                  'Extra Active' => l10n.activityExtraActive,
                  _ => a,
                };
                return DropdownMenuItem(value: a, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _activityLevel = v),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _cookingSkillLevel,
              decoration: InputDecoration(
                labelText: l10n.cookingSkillLevel,
                prefixIcon: const Icon(Icons.restaurant_outlined),
              ),
              items: _skillOptions.map((s) {
                final label = switch (s) {
                  'Beginner' => l10n.skillBeginner,
                  'Intermediate' => l10n.skillIntermediate,
                  'Advanced' => l10n.skillAdvanced,
                  _ => s,
                };
                return DropdownMenuItem(value: s, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _cookingSkillLevel = v),
            ),

            if (authProvider.error != null) ...[
              const SizedBox(height: 16),
              Text(
                authProvider.error!,
                style: const TextStyle(color: AppTheme.errorColor),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),

            GradientButton(
              text: l10n.signUp,
              onPressed: authProvider.isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _goToPage(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.previous),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool active;
  final bool done;
  final String label;

  const _StepDot({
    required this.index,
    required this.active,
    required this.done,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = active || done;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: isHighlighted ? AppTheme.primaryGradient : null,
            color: isHighlighted ? null : AppTheme.neutralLightOf(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: active
                          ? Colors.white
                          : AppTheme.textTertiaryOf(context),
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isHighlighted
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiaryOf(context),
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
