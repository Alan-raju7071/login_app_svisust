import 'package:flutter/material.dart';
import 'package:login_app_svisust/screens/login_screen.dart';
import 'package:login_app_svisust/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    await prefs.setString("name", nameController.text.trim());
    await prefs.setString("email", emailController.text.trim());
    await prefs.setString("password", passwordController.text.trim());

    
    await prefs.setBool("isLoggedIn", false);

    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: nameController,
                    hintText: "Full Name",
                    validator: (value) =>
                        value!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 16),

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
                        value!.length < 6 ? "Min 6 chars" : null,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _register,
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
