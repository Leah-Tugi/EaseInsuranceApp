import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/widgets/OutlineInputWidget.dart';
import '../viewmodels/AuthViewModel.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _profileImageController = TextEditingController(text: "https://default_profile_image.url"); // Placeholder
  final _formKey = GlobalKey<FormState>();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Sample userId generation (you could use a UUID generator here)
      final String userId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create the user data object to register
      final newUser = {
        "createdAt": DateTime.now().toIso8601String(),
        "fullName": _fullNameController.text,
        "profileImage": _profileImageController.text,
        "nationalId": _nationalIdController.text,
        "phoneNumber": _phoneNumberController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      // Log the data being sent to the server
      print('Sending the following data to the server: $newUser');

      // Call the register method in AuthProvider to handle registration
      try {
        final response = await Provider.of<AuthProvider>(context, listen: false).register(newUser);

        // Log the response from the server
        print('Received response from the server: $response');

        // Navigate to the Insurance List page after successful registration
        Navigator.pushReplacementNamed(context, '/insuranceList');
      } catch (error) {
        print('Error during registration: $error');
        // Handle error appropriately, e.g., show a message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              OutlineInputWidget(
                controller: _fullNameController,
                label: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your full name';
                  }
                  return null;
                },
              ),
              OutlineInputWidget(
                controller: _emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              OutlineInputWidget(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  }
                  return null;
                },
              ),
              OutlineInputWidget(
                controller: _nationalIdController,
                label: 'National ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your national ID';
                  }
                  return null;
                },
              ),
              OutlineInputWidget(
                controller: _phoneNumberController,
                label: 'Phone Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your phone number';
                  }
                  return null;
                },
              ),
              OutlineInputWidget(
                controller: _profileImageController,
                label: 'Profile Image URL',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
