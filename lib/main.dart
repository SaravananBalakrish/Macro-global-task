import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:macro_global_task/providers/auth_provider.dart';
import 'package:macro_global_task/providers/task_provider.dart';
import 'package:macro_global_task/screens/auth/login_screen.dart';
import 'package:macro_global_task/screens/task/task_list_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authProvider = AuthProvider();
  final storedUser = await authProvider.getStoredUser();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => authProvider),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: MyApp(isLoggedIn: storedUser != null),
      )
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macro Global Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? TaskListScreen() : LoginScreen(),
    );
  }
}
