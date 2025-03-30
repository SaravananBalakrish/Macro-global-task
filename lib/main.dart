import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:macro_global_task/repositories/auth_repository.dart';
import 'package:macro_global_task/utils/theme.dart';
import 'package:macro_global_task/view_models/theme_view_model.dart';
import 'package:provider/provider.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/task_view_model.dart';
import 'views/auth/login_screen.dart';
import 'views/task/task_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authRepository = AuthRepository();
  final localAuth = LocalAuthentication();
  final secureStorage = const FlutterSecureStorage();
  final firestore = FirebaseFirestore.instance;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(
          authRepository: authRepository,
          localAuth: localAuth,
          storage: secureStorage,
          firestore: firestore,
        )),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    return MaterialApp(
      title: 'Macro Global Task',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      home: authViewModel.currentUser != null ? const TaskListScreen() : const LoginScreen(),
    );
  }
}