import 'package:flutter/material.dart';
import 'package:login_app_svisust/screens/registration_screen.dart';
import 'package:login_app_svisust/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get stored values from registration
      String? storedEmail = prefs.getString("email");
      String? storedPassword = prefs.getString("password");
      String? storedName = prefs.getString("name");

      // Validate credentials
      if (storedEmail == emailController.text.trim() &&
          storedPassword == passwordController.text.trim()) {
        // Save login session
        await prefs.setBool("isLoggedIn", true);

        // Navigate to profile screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        // Show error if credentials don't match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Login",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                    validator: (value) =>
                        value!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? "Enter password" : null,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
