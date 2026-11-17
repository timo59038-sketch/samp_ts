import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samp_ts/screens/auth_screen.dart';
import 'package:samp_ts/services/auth_service.dart';

class FakeAuthService implements AuthService {
  int signIns = 0;
  int registrations = 0;
  @override
  Future<void> signIn(String email, String password) async {
    signIns++;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    registrations++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Invalid login is blocked and valid login calls authentication', (
    tester,
  ) async {
    final service = FakeAuthService();
    await tester.pumpWidget(MaterialApp(home: AuthScreen(service: service)));
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(service.signIns, 0);
    expect(find.text('Enter a valid email.'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(service.signIns, 1);
  });
  testWidgets('Registration requires a name and stronger password', (
    tester,
  ) async {
    final service = FakeAuthService();
    await tester.pumpWidget(MaterialApp(home: AuthScreen(service: service)));
    await tester.ensureVisible(find.text('New here? Create an account'));
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'student@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(service.registrations, 0);
    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
  });
}
