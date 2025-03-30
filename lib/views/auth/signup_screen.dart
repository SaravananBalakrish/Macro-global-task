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

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3C8CE7), Color(0xFF00EAFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(controller: nameController, label: "Full Name", icon: Icons.person),
                          const SizedBox(height: 10),
                          _buildTextField(controller: emailController, label: "Email", icon: Icons.email),
                          const SizedBox(height: 10),
                          _buildTextField(controller: phoneController, label: "Phone Number", icon: Icons.phone, keyboardType: TextInputType.phone),
                          const SizedBox(height: 10),
                          _buildTextField(controller: passwordController, label: "Password", icon: Icons.lock, isPassword: true),
                          const SizedBox(height: 20),
                          authViewModel.isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                            children: [
                              _buildButton(
                                text: "Sign Up",
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    String result = await authViewModel.signUp(
                                      nameController.text,
                                      emailController.text,
                                      passwordController.text,
                                      phoneController.text,
                                    );
                                    if (result == "Signup successful!") {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildButton(
                                text: "Sign Up with Google",
                                onPressed: () async {
                                  String result = await authViewModel.signInWithGoogle();
                                  if (result == "Google Sign-In successful!") {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                                  }
                                },
                                isGoogle: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                            child: const Text(
                              "Already have an account? Login",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? "$label cannot be empty" : null,
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed, bool isGoogle = false}) {
    return ElevatedButton.icon(
      icon: isGoogle ? const Icon(Icons.g_translate, color: Colors.red) : const Icon(Icons.person_add),
      label: Text(text, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isGoogle ? Colors.white : Colors.blueAccent,
        foregroundColor: isGoogle ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
    );
  }
}