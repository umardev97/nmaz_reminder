import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

AppException appExceptionFromError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  return AppException(userMessageFromError(error, fallback: fallback));
}

String userMessageFromError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is AppException) return error.message;
  if (error is FirebaseAuthException) return _authMessage(error);
  if (error is FirebaseException) return _firebaseMessage(error, fallback);
  if (error is PlatformException) return _platformMessage(error, fallback);
  if (error is FormatException) {
    return 'Some information was not in the expected format. Please try again.';
  }

  final message = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (message.trim().isEmpty || message == 'null') return fallback;
  return message;
}

String _authMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'The email or password is incorrect.';
    case 'email-already-in-use':
      return 'This email is already registered. Try signing in instead.';
    case 'weak-password':
      return 'Please choose a stronger password.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'requires-recent-login':
      return 'For security, please sign out and sign in again before deleting your account.';
    case 'network-request-failed':
      return 'You seem to be offline. Check your connection and try again.';
    case 'invalid-verification-code':
      return 'The verification code is incorrect. Please check it and try again.';
    case 'invalid-verification-id':
    case 'session-expired':
      return 'This verification session has expired. Please request a new code.';
    case 'quota-exceeded':
      return 'SMS verification is temporarily unavailable. Please try again later.';
    case 'missing-phone-number':
    case 'invalid-phone-number':
      return 'Please enter a valid phone number.';
    default:
      return error.message ?? 'Authentication failed. Please try again.';
  }
}

String _firebaseMessage(FirebaseException error, String fallback) {
  switch (error.code) {
    case 'permission-denied':
      return 'You do not have permission to do that. Please sign in again.';
    case 'unavailable':
      return 'The service is currently unavailable. Check your connection and try again.';
    case 'deadline-exceeded':
      return 'The request took too long. Please try again.';
    case 'not-found':
      return 'We could not find the requested information.';
    case 'already-exists':
      return 'This information already exists.';
    case 'resource-exhausted':
      return 'The service is busy right now. Please try again in a moment.';
    case 'cancelled':
      return 'The request was cancelled. Please try again.';
    default:
      return error.message ?? fallback;
  }
}

String _platformMessage(PlatformException error, String fallback) {
  switch (error.code) {
    case 'network_error':
    case 'network-request-failed':
      return 'You seem to be offline. Check your connection and try again.';
    case 'permission_denied':
      return 'Permission was denied. Please update your settings and try again.';
    default:
      return error.message ?? fallback;
  }
}
