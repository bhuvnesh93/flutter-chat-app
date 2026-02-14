import 'package:chat_app/screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // SharedPreferences.getInstance() is an asynchronous operation.
  // In a Provider, you typically provide the instance directly after awaiting it.
  // For more complex async initialization, consider using FutureProvider.
  throw UnimplementedError('SharedPreferences must be initialized');
});

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     name: "fir-example-43093",
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const ProviderScope(child: App()));
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "fir-example-43093",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
