import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:checkpoint_geofence/Forms/register.dart';

enum UserRole {
  contestant,
  organizer,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Image.asset(
                'lib/assets/picture_assets/loginlogo.png',
                width: 200,
                height: 150,
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      items: [
                        DropdownMenuItem<UserRole>(
                          value: UserRole.contestant,
                          child: Text('Contestant'),
                        ),
                        DropdownMenuItem<UserRole>(
                          value: UserRole.organizer,
                          child: Text('Organizer'),
                        ),
                      ],
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Role'),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _loginAsSpectator();
                              }
                            },
                            child: const Text('Login As Spectator'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Logged in successfully, perform role-specific actions
        switch (_selectedRole) {
          case UserRole.contestant:
            // Perform actions for contestant role
            break;
          case UserRole.organizer:
            // Perform actions for organizer role
            break;
        }

        // Clear the form and navigate to the home screen
        _formKey.currentState!.reset();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  Future<void> _loginAsSpectator() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();

      final User? user = userCredential.user;

      if (user != null) {
        // Clear the form and navigate to the home screen
        _formKey.currentState!.reset();
        Navigator.pushReplacementNamed(context, '/home');
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