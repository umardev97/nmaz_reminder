import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';
import '../models/app_user.dart';
import '../auth_repository.dart';

final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider = Provider((ref) => AuthRepository());

final firebaseUserProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
});

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
    final svc = ref.read(authServiceProvider);
    return svc.signInWithEmail(email, password);
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

      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
  Future<void> signOut() async {
    final svc = ref.read(authServiceProvider);
    await svc.signOut();
  }
}

final authControllerProvider = Provider((ref) => AuthController(ref));
