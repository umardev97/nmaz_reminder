import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';

class PhoneVerifyPage extends ConsumerStatefulWidget {
  const PhoneVerifyPage({super.key, required this.verificationId});

  final String verificationId;

  @override
  ConsumerState<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends ConsumerState<PhoneVerifyPage> {
  final _codeCtl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeCtl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeCtl.text.trim().length < 6) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithSmsCode(
            widget.verificationId,
            _codeCtl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('That code was not accepted. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AppPage(
        maxWidth: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(height: 68, compact: true),
            const SizedBox(height: 30),
            Text('Verify your phone',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 10),
            Text(
              'Enter the six-digit code sent to your phone.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _codeCtl,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(letterSpacing: 10),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)
              ],
              decoration: const InputDecoration(hintText: '000000'),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 22),
            FullWidthButton(
              label: 'Verify and continue',
              icon: Icons.verified_user_outlined,
              loading: _loading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
