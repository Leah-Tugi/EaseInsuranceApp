import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserData.dart';
import '../utils/widgets/OutlineInputWidget.dart';
import '../viewmodels/AuthViewModel.dart';

class ProfileScreen extends StatefulWidget {
  final String userId; // Pass userId to ProfileScreen

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIdController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _nationalIdController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _usernameController.text = prefs.getString('fullName') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
      _nationalIdController.text = prefs.getString('nationalId') ?? '';
    });
  }

  Future<void> _saveProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('fullName', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('phoneNumber', _phoneController.text);
    await prefs.setString('nationalId', _nationalIdController.text);

    final createdAtString = prefs.getString('createdAt');
    DateTime? createdAt;

    if (createdAtString != null) {
      createdAt = DateTime.parse(createdAtString);
    } else {
      createdAt = DateTime.now();
    }

    final updatedUser = UserData(
      userId: widget.userId,
      fullName: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phoneNumber: _phoneController.text,
      nationalId: _nationalIdController.text,
      createdAt: createdAt,
      profileImage: prefs.getString('profileImage'),
    );

    bool success = await Provider.of<AuthProvider>(context, listen: false)
        .updateUser(updatedUser);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } else {
      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                OutlineInputWidget(
                  controller: _usernameController,
                  label: 'Username',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                ),
                OutlineInputWidget(
                  controller: _emailController,
                  label: 'Email',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an email' : null,
                ),
                OutlineInputWidget(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true, // Hide password input
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                ),
                OutlineInputWidget(
                  controller: _phoneController,
                  label: 'Phone Number',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a phone number' : null,
                ),
                OutlineInputWidget(
                  controller: _nationalIdController,
                  label: 'National ID',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your national ID' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfileData,
                  // Save profile data to SharedPreferences and backend
                  child: Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
