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
  UserRole? _selectedRole;
  String _errorMessage = '';

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
    );
  }

Future<void> _register() async {
  if (_selectedRole == UserRole.contestant) {
    // Clear the form and close the dialog
    _formKey.currentState!.reset();
    Navigator.pop(context); // Close the register dialog
  } else {
    try {
      if (_formKey.currentState!.validate()) {
        // Register with Firebase Authentication
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
}
