import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/widgets/OutlineInputWidget.dart'; // Ensure you import your custom widget
import '../viewmodels/AuthViewModel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              SizedBox(height: 16), // Add some spacing
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userId = await Provider.of<AuthProvider>(context, listen: false)
                        .login(_emailController.text, _passwordController.text);

                    // Check if login was successful
                    if (userId != null) {
                      // Navigate to the insurance list page, passing the userId
                      Navigator.pushNamed(context, '/insuranceList', arguments: userId);
                    } else {
                      // Show an error message if login failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed. Please check your credentials.')),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity, // Make button full width
                  height: 50, // Set height
                  margin: EdgeInsets.symmetric(horizontal: 16), // Set horizontal margin
                  child: Center(child: Text('Login')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
