import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/app_error.dart';
import '../auth_service.dart';
import '../models/app_user.dart';
import '../auth_repository.dart';

final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider = Provider((ref) => AuthRepository());

final firebaseUserProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.userChanges();
});

bool needsEmailVerification(User user) {
  final hasEmailPasswordProvider =
      user.providerData.any((provider) => provider.providerId == 'password');
  final hasEmail = user.email?.trim().isNotEmpty == true;
  return hasEmailPasswordProvider && hasEmail && !user.emailVerified;
}

final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(firebaseUserProvider).asData?.value;
  if (user == null) return null;
  final repo = ref.watch(authRepositoryProvider);
  final maybe = await repo.fetchUser(user.uid);
  if (maybe == null) {
    final appUser = AppUser(uid: user.uid, name: user.displayName ?? '');
    await repo.createUserIfNotExists(appUser);
    return appUser;
  }
  return maybe;
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<UserCredential> signInEmail(String email, String password) async {
    try {
      final svc = ref.read(authServiceProvider);
      return await svc.signInWithEmail(email, password);
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'Sign in failed. Check your details and try again.',
      );
    }
  }

  Future<UserCredential> registerEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final svc = ref.read(authServiceProvider);

      final cred = await svc.registerWithEmail(email, password);

      final repo = ref.read(authRepositoryProvider);

      final appUser = AppUser(
        uid: cred.user!.uid,
        name: name,
        email: email,
      );

      await repo.createUserIfNotExists(appUser);
      await svc.sendEmailVerification();

      return cred;
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'We could not create your account. Please try again.',
      );
    }
  }

  Future<UserCredential> verifySmsCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final svc = ref.read(authServiceProvider);
      return await svc.signInWithSmsCode(verificationId, smsCode);
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'That code was not accepted. Please try again.',
      );
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final svc = ref.read(authServiceProvider);
      await svc.sendEmailVerification();
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'We could not send the verification email. Please try again.',
      );
    }
  }

  Future<User?> reloadCurrentUser() async {
    try {
      final svc = ref.read(authServiceProvider);
      return await svc.reloadCurrentUser();
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'We could not refresh your account. Please try again.',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final svc = ref.read(authServiceProvider);
      final user = svc.currentUser;
      if (user == null) {
        throw const AppException('No signed-in account was found.');
      }
      final lastSignInTime = user.metadata.lastSignInTime;
      if (lastSignInTime == null ||
          DateTime.now().difference(lastSignInTime) >
              const Duration(minutes: 5)) {
        throw const AppException(
          'For security, please sign out and sign in again before deleting your account.',
        );
      }

      await ref.read(authRepositoryProvider).deleteUserData(user.uid);
      await svc.deleteCurrentUser();
    } catch (e) {
      throw appExceptionFromError(
        e,
        fallback: 'We could not delete your account. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    final svc = ref.read(authServiceProvider);
    await svc.signOut();
  }
}

final authControllerProvider = Provider((ref) => AuthController(ref));
