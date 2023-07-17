import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

enum UserRole {
  contestant,
  organizer,
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({Key? key}) : super(key: key);

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole? _selectedRole;
  String _errorMessage = '';
  bool _passwordObscure = true;
  bool _confirmPasswordObscure = true;
  bool _isLoading = false;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Full Name (Please Enter Your Name Accordingly)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
              controller: _passwordController,
              obscureText: _passwordObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                    icon: Icon(_passwordObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordObscure = !_passwordObscure;
                      });
                    }
                ),
                ),
            ),
                  TextFormField(
              controller: _confirmPasswordController,
              obscureText: _confirmPasswordObscure,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(_confirmPasswordObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordObscure = !_confirmPasswordObscure;
                    });
                  }
                ),
              ),
              validator: (value) {
                if(_passwordController.text != _confirmPasswordController.text) {
                  return 'Incorrect Password';
              }
                return null;
              }
            ),
            
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
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
              onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text("Registering..."),
                        ],
                      ),
                    ),
                  );

                  await _register();

                  Navigator.pop(context); // Pop loading dialog
                  
                  setState(() {
                    _isLoading = false;
                  });

                },
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                                    primary:Color(0xFFFC766A),
                ),
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
    );
  }

Future<void> _register() async {
  try {
    if (_formKey.currentState!.validate()) {
      // Register with Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Store user details in the Firebase Realtime Database
        final DatabaseReference userRef =
            dbRef.child('users').child(user.uid);

        await userRef.set({
          'email': _emailController.text.trim(),
          'fullname': _usernameController.text.trim(),
          'role': _selectedRole.toString(),
          // Add other user details as needed
        });

        // Clear the form and close the dialog
        _formKey.currentState!.reset();
        Navigator.pop(context); // Close the register dialog
      }
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = e.message!;
    });
  }
}
}
