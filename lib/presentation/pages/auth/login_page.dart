import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_utils.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';
import '../auth_gate.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final credential = await ref.read(authControllerProvider).signInEmail(
            _emailCtl.text.trim(),
            _passCtl.text,
          );
      if (!mounted) return;
      final user = credential.user;
      if (user != null && needsEmailVerification(user)) {
        // Admins bypass email verification — check role before blocking.
        final appUser =
            await ref.read(authRepositoryProvider).fetchUser(user.uid);
        if (!mounted) return;
        if (appUser?.role == 'admin') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (_) => false,
          );
          return;
        }
        await ref.read(authControllerProvider).sendEmailVerification();
        if (!mounted) return;
        await _showEmailVerificationDialog();
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e,
        fallback: 'Sign in failed. Check your details and try again.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showEmailVerificationDialog() async {
    final verified = await AppDialogs.showEmailVerification(
      context,
      email: _emailCtl.text.trim(),
    );

    if (!verified) {
      await ref.read(authControllerProvider).signOut();
      if (!mounted) return;
      AppSnackBar.show(
        context,
        'Please verify your email. We sent a verification email to your inbox.',
      );
      return;
    }

    final user = await ref.read(authControllerProvider).reloadCurrentUser();
    if (!mounted) return;
    if (user != null && !needsEmailVerification(user)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (_) => false,
      );
      return;
    }

    await ref.read(authControllerProvider).signOut();
    if (!mounted) return;
    AppSnackBar.show(
      context,
      'Email is not verified yet. Please verify your email and sign in again.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: AppPage(
          maxWidth: 520,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogo(height: 168),
              const SizedBox(height: 36),
              Text('Welcome back',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your daily prayer journey.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Enter a valid email address'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtl,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _signIn(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    FullWidthButton(
                      label: 'Sign in',
                      icon: Icons.login_rounded,
                      loading: _loading,
                      onPressed: _signIn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Nmaz Reminder?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
