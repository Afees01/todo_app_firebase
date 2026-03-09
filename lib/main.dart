import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_providers.dart';
import 'package:todo_app/views/auth/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmxJCYXpXJqQi1ABO_z3KpW-Jl8NViH60",
      appId: "1:84661297363:web:f30b4d5a1d99835eb4b426",
      messagingSenderId: "84661297363",
      projectId: "todo-flutter-app-98014",
      authDomain: "todo-flutter-app-98014.firebaseapp.com",
      storageBucket: "todo-flutter-app-98014.firebasestorage.app",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginView(),
    );
  }
}
