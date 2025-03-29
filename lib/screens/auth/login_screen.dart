import 'package:flutter/material.dart';
import 'package:macro_global_task/screens/auth/signup_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../task/task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TaskListScreen()));
    } catch (e, stackTrace) {
      print("e in _login :: $e");
      print("stackTrace in _login :: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  void _loginWithGoogle(BuildContext context) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TaskListScreen()));
    } catch (e, stackTrace) {
      print("e in _loginWithGoogle :: $e");
      print("stackTrace in _loginWithGoogle :: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /*void _loginWithBiometrics(BuildContext context) async {
    await Provider.of<BiometricProvider>(context, listen: false).authenticate();
    if (Provider.of<BiometricProvider>(context, listen: false).isAuthenticated) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TaskListScreen()));
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains("@")) return "Enter a valid email";
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: false,
                validator: (value) {
                  if (value == null || value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => _login(context),
                child: Text("Login"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _loginWithGoogle(context),
                child: Text("Login with Google"),
              ),
              /*SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _loginWithBiometrics(context),
                child: Text("Login with Biometrics"),
              ),*/
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                },
                child: Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
