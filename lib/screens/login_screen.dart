import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Forms/register.dart';
import '../main.dart';
import '../models/checkpoint.dart';
import '../organizer/organizer_menu.dart';
import '../screens/home_screen.dart';

enum UserRole {
  contestant,
  organizer,
}

class LoginScreen extends StatefulWidget {
  final List<Checkpoint> checkpoints;

  const LoginScreen({Key? key, required this.checkpoints}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
      body: Container(
        color: Colors.black, // Set the background color to black
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(70.0),
                    child: Column(
                      children: [
                        Container(
                          height: 150,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'lib/assets/picture_assets/loginlogo.png',
                            width: 250,
                            height: 350,
                          ),
                        ),
                        SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0,
                                    horizontal: 16.0,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 16.0,
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<UserRole>(
                                value: _selectedRole,
                                items: [
                                  DropdownMenuItem<UserRole>(
                                    value: UserRole.contestant,
                                    child: const Text('Contestant'),
                                  ),
                                  DropdownMenuItem<UserRole>(
                                    value: UserRole.organizer,
                                    child: const Text('Organizer'),
                                  ),
                                ],
                                onChanged: (UserRole? value) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 16.0,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a role';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                  child: const Text('Login'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    textStyle: TextStyle(fontSize: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  child: const Text('Register'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    textStyle: TextStyle(fontSize: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      final String email = _emailController.text.trim();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Logged in successfully, perform role-specific actions
        switch (_selectedRole) {
          case UserRole.contestant:
            // Perform actions for contestant role
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  checkpoints: widget.checkpoints,
                  email: email,
                ),
              ),
            );
            break;
          case UserRole.organizer:
            // Perform actions for organizer role
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrganizerMenu(checkpoints: widget.checkpoints),
              ),
            );
            break;
        }

        // Clear the form
        _formKey.currentState!.reset();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  Future<void> _register() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegisterDialog();
      },
    );
  }
}
