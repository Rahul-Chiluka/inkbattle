import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class AppleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  // Sign in with Apple and register/login with backend.
  Future<AuthResponse?> signInWithApple() async {
    try {
      // Trigger Apple Sign-In flow.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Build OAuth credential for Firebase.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Prefer name from Apple if provided, else from Firebase user.
      final displayName = [
        appleCredential.givenName,
        appleCredential.familyName
      ].where((v) => v != null && v.isNotEmpty).join(' ').trim();

      final resolvedName = displayName.isNotEmpty
          ? displayName
          : (userCredential.user?.displayName ?? 'Apple User');

      // Register/Login with backend.
      final result = await _retryBackendSignup(
        provider: 'apple',
        providerId: userCredential.user!.uid,
        name: resolvedName,
        avatar: AppImages.av3,
      );

      return result.fold(
        (failure) {
          print('Backend signup failed: ${failure.toString()}');
          return null;
        },
        (authResponse) => authResponse,
      );
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Retry logic with exponential backoff (same pattern as Google).
  Future<Either<Failure, AuthResponse>> _retryBackendSignup({
    required String provider,
    required String providerId,
    required String name,
    String? avatar,
  }) async {
    int maxRetries = 3;
    int delayMs = 1000;

    for (int i = 0; i < maxRetries; i++) {
      try {
        final result = await _userRepository.signup(
          provider: provider,
          providerId: providerId,
          name: name,
          avatar: avatar,
        );

        if (result.isRight()) {
          return result;
        }

        if (i == maxRetries - 1) {
          return result;
        }

        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      } catch (e) {
        print('Retry $i failed: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }

    return left(ApiFailure(message: 'Max retries exceeded'));
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
