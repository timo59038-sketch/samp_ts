import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (error, stack) {
    debugPrint('Firebase initialization failed: $error\n$stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error is UnsupportedError
                    ? error.message?.toString() ?? 'Platform not configured.'
                    : 'Unable to start SAMPTS. Please close the app and try again.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SAMPTS',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: AuthGate(
      service: AuthService(FirebaseAuth.instance, FirebaseDatabase.instance),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.service});
  final AuthService service;
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: service.changes,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(
            child: Text('Unable to load your session. Restart the app.'),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      return user == null
          ? AuthScreen(service: service)
          : ProfileScreen(
              key: ValueKey(user.uid),
              service: service,
              user: user,
            );
    },
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.service, required this.user});
  final AuthService service;
  final User user;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> profile;
  @override
  void initState() {
    super.initState();
    profile = widget.service.ensureProfile(widget.user);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SAMPTS'),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              await widget.service.signOut();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to sign out. Please try again.'),
                  ),
                );
              }
            }
          },
          child: const Text('Sign out'),
        ),
      ],
    ),
    body: FutureBuilder<void>(
      future: profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Signed in, but your profile could not be loaded.'),
                FilledButton(
                  onPressed: () => setState(() {
                    profile = widget.service.ensureProfile(widget.user);
                  }),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 64),
                Text(
                  'You are signed in',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(widget.user.email ?? 'Google account'),
                const SizedBox(height: 16),
                const Text(
                  'Your SAMPTS profile is ready. Meeting and project screens are coming next.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
