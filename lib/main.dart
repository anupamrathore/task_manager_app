// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: when using real Back4App Parse SDK, initialize here.
  // For now we're using the local parse_stub, so skip calling Parse.init().
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager (stub)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: false,
      ),
      home: const LoginScreen(),
      routes: {
        '/': (ctx) => const LoginScreen(),
      },
    );
  }
}
