import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../task/task_list_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Welcome Back", style: theme.textTheme.headlineLarge),
                          const SizedBox(height: 8),
                          Text("Log in to continue", style: theme.textTheme.bodySmall),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email cannot be empty";
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(authViewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => authViewModel.togglePasswordVisibility(),
                              ),
                            ),
                            obscureText: !authViewModel.isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          authViewModel.isLoading
                              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary))
                              : Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate() && authViewModel.emailError == null && authViewModel.passwordError == null) {
                                    String result = await authViewModel.login(emailController.text, passwordController.text);
                                    if (result == "Login successful!") {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                                child: const Text("Login", style: TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  String result = await authViewModel.signInWithGoogle();
                                  if (result == "Google Sign-In successful!") {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                  }
                                },
                                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                                label: const Text("Login with Google"),
                                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                              ),
                              /*if (authViewModel.isSupported) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    bool success = await authViewModel.loginWithBiometrics();
                                    if (success) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometric login failed")));
                                    }
                                  },
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text("Login with Biometrics"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                ),
                              ],*/
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ", style: theme.textTheme.bodySmall),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                child: Text("Sign up", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}