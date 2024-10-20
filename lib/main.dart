import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // นำเข้า Firestore
import 'package:flutter_6_9/screen/signin_screen.dart';
import 'package:flutter_6_9/firebase_options.dart';
import 'package:flutter_6_9/screen/signup_screen.dart'; // นำเข้า firebase_options.dart ที่สร้างจาก FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue, // สีหลักเดิม
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey, // เปลี่ยนเป็นโทนสีฟ้า-เทาที่นุ่มนวล
        ).copyWith(
          secondary: Colors.lightBlueAccent, // สีที่ละมุนสำหรับการกระทำหรือปุ่มต่าง ๆ
          surface: Colors.white, // สีพื้นหลังของการ์ด
          background: Colors.blueGrey.shade50, // สีพื้นหลังของแอปโดยรวม
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black54),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey.shade200, // สี AppBar ที่ละมุนขึ้น
          titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      initialRoute: '/signup',  // กำหนดหน้าแรกเป็น Signup
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SigninScreen(),
        '/todo': (context) => const TodoApp(),
      },
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  bool _completed = false; // สถานะทำเสร็จหรือไม่

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailsController = TextEditingController();
  }

  // ฟังก์ชันเพิ่มข้อมูลลง Firestore
  void addTodoToFirestore(String title, String details, bool completed) {
    FirebaseFirestore.instance.collection('todos').add({
      'title': title,
      'details': details,
      'completed': completed,
    }).then((value) {
      print("Todo Added");
    }).catchError((error) {
      print("Failed to add todo: $error");
    });
  }

  // ฟังก์ชันแก้ไขข้อมูลใน Firestore
  void updateTodoInFirestore(String docId, String title, String details, bool completed) {
    FirebaseFirestore.instance.collection('todos').doc(docId).update({
      'title': title,
      'details': details,
      'completed': completed,
    }).then((value) {
      print("Todo Updated");
    }).catchError((error) {
      print("Failed to update todo: $error");
    });
  }

  // ฟังก์ชันลบข้อมูลจาก Firestore
  void deleteTodoFromFirestore(String docId) {
    FirebaseFirestore.instance.collection('todos').doc(docId).delete().then((value) {
      print("Todo Deleted");
    }).catchError((error) {
      print("Failed to delete todo: $error");
    });
  }

  // ฟังก์ชันเปิด Dialog เพื่อเพิ่มหรือแก้ไขข้อมูล
  void showTodoDialog(BuildContext context, {String? docId, String? title, String? details, bool? completed}) {
    _titleController.text = title ?? '';
    _detailsController.text = details ?? '';
    _completed = completed ?? false; // กำหนดค่าเริ่มต้นของสถานะ

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Add new task" : "Edit task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task title",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task details",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Completed: "),
                  Checkbox(
                    value: _completed,
                    onChanged: (value) {
                      setState(() {
                        _completed = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (docId == null) {
                  // เพิ่มข้อมูลใหม่
                  addTodoToFirestore(_titleController.text, _detailsController.text, _completed);
                } else {
                  // แก้ไขข้อมูลเดิม
                  updateTodoInFirestore(docId, _titleController.text, _detailsController.text, _completed);
                }
                _titleController.clear();
                _detailsController.clear();
                Navigator.pop(context);
              },
              child: Text(docId == null ? "Save" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // ล็อกเอาต์จาก Firebase
              Navigator.pushReplacementNamed(context, '/signin'); // นำทางกลับไปที่หน้า Signin
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('todos').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              var todo = todos[index];
              final data = todo.data() as Map<String, dynamic>; // แปลงข้อมูลให้เป็น Map

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      data['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                        decoration: (data.containsKey('completed') && data['completed'])
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      data['details'],
                      style: TextStyle(color: Colors.blueGrey.shade500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showTodoDialog(
                              context,
                              docId: todo.id,
                              title: data['title'],
                              details: data['details'],
                              completed: data.containsKey('completed') ? data['completed'] : false,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTodoFromFirestore(todo.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTodoDialog(context); // เปิด Dialog เพื่อเพิ่มข้อมูลใหม่
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
