import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.service});
  final AuthService service;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool registering = false, busy = false, obscure = true;
  String? message;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> perform(Future<void> Function() action) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } on GoogleSignInException catch (error) {
      if (mounted) {
        setState(
          () => message = error.code == GoogleSignInExceptionCode.canceled
              ? 'Google sign-in was cancelled.'
              : 'Google sign-in failed. Check your connection and try again.',
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => message = switch (error.code) {
            'invalid-credential' ||
            'wrong-password' ||
            'user-not-found' => 'Email or password is incorrect.',
            'email-already-in-use' =>
              'This email already has an account. Please sign in.',
            'weak-password' => 'Choose a stronger password.',
            'network-request-failed' =>
              'Check your internet connection and try again.',
            'too-many-requests' => 'Too many attempts. Please try again later.',
            'account-exists-with-different-credential' =>
              'Sign in using your original sign-in method.',
            _ => 'Authentication failed. Please try again.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Unable to continue. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    perform(
      () => registering
          ? widget.service.register(name.text, email.text, password.text)
          : widget.service.signIn(email.text, password.text),
    );
  }

  void reset() {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim())) {
      setState(() => message = 'Enter your email address first.');
      return;
    }
    perform(() async {
      await widget.service.resetPassword(email.text);
      if (mounted) {
        setState(
          () => message = 'If an account exists, a reset email has been sent.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AutofillGroup(
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.school_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'SAMPTS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text(
                    'Student–Advisor Meeting & Project Tracking',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    registering
                        ? 'Create your student account'
                        : 'Welcome back',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  if (registering) ...[
                    TextFormField(
                      controller: name,
                      enabled: !busy,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your name.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: email,
                    enabled: !busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(v?.trim() ?? '')
                        ? null
                        : 'Enter a valid email.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    enabled: !busy,
                    obscureText: obscure,
                    autofillHints: [
                      registering
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onFieldSubmitted: (_) {
                      if (!busy) submit();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: obscure ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter your password.'
                        : registering && v.length < 6
                        ? 'Use at least 6 characters.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(message!, semanticsLabel: message),
                    ),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(registering ? 'Create account' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: busy ? null : reset,
                    child: const Text('Forgot password?'),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => perform(widget.service.google),
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            registering = !registering;
                            message = null;
                            password.clear();
                          }),
                    child: Text(
                      registering
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                  if (busy) const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  const Text(
                    'New accounts start as students. Advisor access is assigned by your administrator.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
