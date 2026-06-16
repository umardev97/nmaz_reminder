import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/home_page.dart';
import 'admin/admin_dashboard.dart';
import 'auth/onboarding_page.dart';
import '../widgets/app_ui.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseUserProvider);
    return auth.when(
      data: (u) {
        if (u == null) return const OnboardingPage();
        if (needsEmailVerification(u)) return const OnboardingPage();
        // check app user role
        final appUserAsync = ref.watch(appUserProvider);
        return appUserAsync.when(
          data: (appUser) {
            if (appUser != null && appUser.role == 'admin') {
              return const AdminDashboard();
            }
            return const HomePage();
          },
          loading: () => const Scaffold(body: AppLoadingView()),
          error: (e, st) => const HomePage(),
        );
      },
      loading: () => const Scaffold(body: AppLoadingView()),
      error: (e, st) => const Scaffold(
        body: AppStateView(
          title: 'We could not sign you in',
          message: 'Check your connection and reopen the app.',
          icon: Icons.cloud_off_rounded,
          showLogo: true,
        ),
      ),
    );
  }
}
