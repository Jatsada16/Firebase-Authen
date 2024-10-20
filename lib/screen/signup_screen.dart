import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  // ฟังก์ชันตรวจสอบและลงทะเบียนผู้ใช้
  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // ตรวจสอบว่าไม่ได้เว้นช่องว่าง
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'กรุณากรอกข้อมูลให้ครบ';
      });
      return;
    }

    // ตรวจสอบความเหมือนกันของรหัสผ่าน
    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'รหัสผ่านไม่ตรงกัน';
      });
      return;
    }

    // ตรวจสอบความยาวของรหัสผ่าน
    if (password.length < 8) {
      setState(() {
        errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
      });
      return;
    }

    // ดำเนินการลงทะเบียนผู้ใช้ผ่าน Firebase
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        errorMessage = 'สมัครสมาชิกสำเร็จ';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'เกิดข้อผิดพลาด';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
      ),
      body: Center(
        child: Container(
          height: 420,
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
                "Signup",
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Confirm Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text("Sign up"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // กลับไปที่หน้า Signin เมื่อกดปุ่มนี้
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                child: const Text("Go to Signin"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
