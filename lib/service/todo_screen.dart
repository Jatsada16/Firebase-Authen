import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Todo App!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
