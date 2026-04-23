import 'package:flutter/material.dart';
import 'package:ruethive/services/authentication.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final sectionController = TextEditingController();
  final deptController = TextEditingController();
  final rollController = TextEditingController();

  bool isLoading = false;

  final auth = AuthService();

  

  Future<void> signup() async {
    setState(() => isLoading = true);

    try {
      await auth.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
        sectionController.text.trim(),
        deptController.text.trim(),
        rollController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
              TextField(controller: sectionController, decoration: const InputDecoration(labelText: "Section")),
              TextField(controller: deptController, decoration: const InputDecoration(labelText: "Department")),
              TextField(controller: rollController, decoration: const InputDecoration(labelText: "Roll Number")),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : signup,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}