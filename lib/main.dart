import 'package:flutter/material.dart';
import 'home_page.dart';
import 'admin_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perwira Hostel Store Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'Student';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String role = _role;

    // Convert username to lowercase to ensure case-insensitive comparison
    String usernameLowercase = username.toLowerCase();

    try {
      if (role == 'Student') {
        DatabaseReference studentRef = _database.child('students/$usernameLowercase');
        DataSnapshot studentSnapshot = await studentRef.get();

        if (!studentSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
          return;
        }

        Map studentData = studentSnapshot.value as Map;
        String storedPassword = studentData['password'];

        if (password == storedPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome, $username')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
        }
      } else if (role == 'Admin') {
        DatabaseReference adminRef = _database.child('admins/$usernameLowercase');
        DataSnapshot adminSnapshot = await adminRef.get();

        if (!adminSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
          return;
        }

        Map adminData = adminSnapshot.value as Map;
        String storedPassword = adminData['password'];

        if (password == storedPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome, $username')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Calculate the image size based on screen width
    double imageSize = screenSize.width * 0.4; // Adjust the percentage as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perwira Hostel Store Management', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), // Padding added only on left, right, and bottom
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/logo/logo.png',  // Update with your actual image path
                width: imageSize,  // Adjust width as needed
                height: imageSize,  // Adjust height as needed
              ),
              const SizedBox(height: 0),  // Adjust spacing as needed
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Student'),
                    leading: Radio<String>(
                      value: 'Student',
                      groupValue: _role,
                      onChanged: (String? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                  ListTile(
                    title: const Text('Admin'),
                    leading: Radio<String>(
                      value: 'Admin',
                      groupValue: _role,
                      onChanged: (String? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
