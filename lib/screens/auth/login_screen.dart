import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (mounted) {
        if (authProvider.isBanned) {
          context.go('/banned');
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        color: AppTheme.backgroundOf(context),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 90,
                      height: 90,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 48),
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
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('${l10n.forgotPassword}?'),
                      ),
                    ),
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        authProvider.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    GradientButton(
                      text: l10n.signIn,
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      icon: authProvider.isLoading ? null : Icons.login,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final success = await authProvider.signIn(
                                'test@chefspecials.com',
                                'test123456',
                              );
                              if (success && context.mounted) {
                                if (context.mounted) {
                                  if (context.read<AuthProvider>().isBanned) {
                                    context.go('/banned');
                                  } else {
                                    context.go('/home');
                                  }
                                }
                              }
                            },
                      icon: const Icon(Icons.bolt, size: 18),
                      label: Text(l10n.quickLoginTest),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondaryOf(context),
                        side: BorderSide(color: AppTheme.neutralLightOf(context)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(l10n.noAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
              if (context.canPop())
                Positioned(
                  top: 4,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
