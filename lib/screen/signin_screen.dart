import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If sign-in is successful, navigate to Todo screen
      Navigator.pushReplacementNamed(context, '/todo');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else {
          errorMessage = e.message ?? 'An error occurred.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signin"),
      ),
      body: Center(
        child: Container(
          height: 280,
          width: 300,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0.1, 1),
                  blurRadius: 0.1,
                  spreadRadius: 0.1,
                  color: Colors.black)
            ],
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Signin",
                style: TextStyle(fontSize: 40),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text("Sign in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
