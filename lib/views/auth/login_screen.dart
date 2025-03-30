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

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email", errorText: authViewModel.emailError),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email cannot be empty";
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null; // No error
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  errorText: authViewModel.passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(authViewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => authViewModel.togglePasswordVisibility(),
                  ),
                ),
                obscureText: !authViewModel.isPasswordVisible,
                validator: (value) {
                  if (passwordController.text.length < 6) {
                    return "Password must be at least 6 characters";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 20),
              authViewModel.isLoading
                  ? const CircularProgressIndicator()
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
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String result = await authViewModel.signInWithGoogle();
                      if (result == "Google Sign-In successful!") {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                    child: const Text("Login with Google"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      bool success = await authViewModel.loginWithBiometrics();
                      if (success) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometric login failed")));
                      }
                    },
                    child: const Text("Login with Biometrics"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}