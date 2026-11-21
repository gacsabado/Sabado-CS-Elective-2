import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Google OAuth Client IDs
  static const String _iosClientId =
      '345038281741-skvh0e1ej2eo5bb8p05efi5ab7imqrn1.apps.googleusercontent.com';

  static const String _webClientId =
      '345038281741-nie8e1ge22tqir11pv4bahe5hoqutg6m.apps.googleusercontent.com';

  static bool _googleInitialized = false;

  // Current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  // Authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // EMAIL/PASSWORD SIGN IN
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // EMAIL/PASSWORD SIGN UP
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final redirectUrl = kIsWeb
        ? Uri.base.origin
        : 'hironofinds://login-callback';

    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: redirectUrl,
      data: {'first_name': firstName.trim(), 'last_name': lastName.trim()},
    );
  }

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle() async {
    // Web authentication
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
      return;
    }

    // Initialize Google Sign-In (must only happen once per app run)
    final googleSignIn = GoogleSignIn.instance;

    if (!_googleInitialized) {
      await googleSignIn.initialize(
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );
      _googleInitialized = true;
    }

    // Authenticate with Google
    final googleUser = await googleSignIn.authenticate();

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('Google did not return an ID token.');
    }

    // The access token is optional for Supabase; request it when available.
    String? accessToken;
    try {
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      accessToken = authorization?.accessToken;
    } catch (_) {
      accessToken = null;
    }

    // Authenticate with Supabase. The profile row is created by the
    // handle_new_user database trigger.
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabase.auth.signOut();

    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
  }
}
