import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Spacer(),

              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 10),

              Text(
                "Sign in to continue managing your finances.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              const TextField(decoration: InputDecoration(labelText: "Email")),

              const SizedBox(height: 16),

              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/dashboard');
                  },
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
