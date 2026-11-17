import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService(this.auth, this.database);
  final FirebaseAuth auth;
  final FirebaseDatabase database;
  Future<void>? _googleInitialization;
  Stream<User?> get changes => auth.authStateChanges();
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String name, String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user!.updateDisplayName(name.trim());
    await ensureProfile(result.user!);
    await database.ref('users/${result.user!.uid}').update({
      'name': name.trim(),
    });
  }

  Future<void> google() async {
    if (kIsWeb) {
      await auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    await (_googleInitialization ??= GoogleSignIn.instance.initialize());
    final account = await GoogleSignIn.instance.authenticate();
    final token = account.authentication.idToken;
    if (token == null) throw StateError('Google did not return an ID token.');
    await auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  }

  /// Called after authentication; retrying cannot overwrite an existing role.
  Future<void> ensureProfile(User user) async {
    await database.ref('users/${user.uid}').runTransaction((value) {
      if (value != null) return Transaction.abort();
      return Transaction.success({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'student',
      });
    }, applyLocally: false);
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => auth.signOut();
}
