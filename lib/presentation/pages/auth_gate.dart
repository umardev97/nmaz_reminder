import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/home_page.dart';
import 'admin/admin_dashboard.dart';
import 'auth/onboarding_page.dart';
import '../widgets/app_ui.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/prayer/providers/prayer_notification_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  void _schedulePrayerRemindersAfterLogin(String uid) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(autoSchedulePrayerRemindersProvider)(uid);
      } catch (e) {
        debugPrint('Prayer reminder auto-schedule failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(firebaseUserProvider);
    return auth.when(
      data: (u) {
        if (u == null) return const OnboardingPage();
        final appUserAsync = ref.watch(appUserProvider);
        return appUserAsync.when(
          data: (appUser) {
            if (appUser != null && appUser.role == 'admin') {
              return const AdminDashboard();
            }
            if (needsEmailVerification(u)) return const OnboardingPage();
            _schedulePrayerRemindersAfterLogin(u.uid);
            return const HomePage();
          },
          loading: () => const Scaffold(body: AppLoadingView()),
          error: (e, st) {
            _schedulePrayerRemindersAfterLogin(u.uid);
            return const HomePage();
          },
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
