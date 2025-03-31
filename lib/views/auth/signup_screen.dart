import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../task/task_list_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
    nameController.dispose();
    phoneController.dispose();
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
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Create Account", style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text("Join us today!", style: theme.textTheme.bodySmall),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (value) => value!.isEmpty ? "Name cannot be empty" : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '') ? "Enter a valid email" : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: phoneController,
                            label: "Phone Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) => (value!.length < 10) ? "Enter a valid phone number" : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                            validator: (value) => (value!.length < 6) ? "Password must be at least 6 characters" : null,
                          ),
                          const SizedBox(height: 24),
                          authViewModel.isLoading
                              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary))
                              : Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    String result = await authViewModel.signUp(
                                      nameController.text,
                                      emailController.text,
                                      passwordController.text,
                                      phoneController.text,
                                    );
                                    if (result.contains("Signup successful!")) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                                child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  String result = await authViewModel.signInWithGoogle();
                                  if (result == "Sign-Up with Google successful!" || result == "Google Sign-In successful!") {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                  }
                                },
                                icon: Icon(Icons.g_mobiledata, color: Colors.red),
                                label: const Text("Sign Up with Google"),
                                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ", style: theme.textTheme.bodySmall),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                                child: Text("Login", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}