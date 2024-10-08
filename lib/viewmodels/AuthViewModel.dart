import 'dart:convert';
import 'package:ease_insurance_app/models/UserData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../network/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  UserData? _user;
  bool _isLoggedIn = false;
  String? _userId;
  final AuthService _authService = AuthService();

  UserData? get user => _user;

  bool get isLoggedIn => _isLoggedIn;

  Future<String?> login(String email, String password) async {
    const String baseUrl =
        'https://6703f084ab8a8f8927324c50.mockapi.io/api/v1/users';
    final String requestUrl = '$baseUrl?email=$email';

    print('Request URL: $requestUrl');

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          final user = responseData.first;

          if (user['password'] == password) {
            _userId = user['userId'];
            _isLoggedIn = true;

            await _storeUserData(user);
            print('User data stored successfully.');

            await _printUserData();

            notifyListeners();
            return _userId;
          } else {
            print('Incorrect password for the provided email.');
            return null;
          }
        } else {
          print('No user found with the provided email.');
          return null;
        }
      } else {
        print('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Login error: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      _user = await _authService.registerUser(UserData(
        userId: userData['userId'],
        email: userData['email'],
        password: userData['password'],
        createdAt: DateTime.parse(userData['createdAt']),
        fullName: userData['fullName'],
        profileImage: userData['profileImage'],
        nationalId: userData['nationalId'],
        phoneNumber: userData['phoneNumber'],
      ));

      if (_user != null) {
        _isLoggedIn = true;

        // Store user data in shared preferences
        await _storeUserData({
          'userId': _user?.userId,
          'email': _user?.email,
          'fullName': _user?.fullName,
          'profileImage': _user?.profileImage,
          'nationalId': _user?.nationalId,
          'phoneNumber': _user?.phoneNumber,
          'password': _user?.password,
        });
        print('User data stored successfully after registration.');

        // Retrieve and print user data to verify
        await _printUserData();

        return {
          'userId': _user?.userId,
          'email': _user?.email,
          'fullName': _user?.fullName,
          'profileImage': _user?.profileImage,
          'nationalId': _user?.nationalId,
          'phoneNumber': _user?.phoneNumber,
          'password': _user?.password,
        };
      }
    } catch (error) {
      print('Registration failed: $error');
    }

    notifyListeners();
    return null;
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', data['userId']);
    await prefs.setString('email', data['email']);
    await prefs.setString('fullName', data['fullName']);
    await prefs.setString('profileImage', data['profileImage']);
    await prefs.setString('nationalId', data['nationalId']);
    await prefs.setString('phoneNumber', data['phoneNumber']);
    await prefs.setString('password', data['password']);
  }

  Future<void> _printUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Retrieved User Data:');
    print('UserId: ${prefs.getString('userId')}');
    print('Email: ${prefs.getString('email')}');
    print('Full Name: ${prefs.getString('fullName')}');
    print('Profile Image: ${prefs.getString('profileImage')}');
    print('National ID: ${prefs.getString('nationalId')}');
    print('Phone Number: ${prefs.getString('phoneNumber')}');
    print(
        'Password: ${prefs.getString('password')}'); // Avoid logging passwords in production
  }

  Future<Map<String, dynamic>?> getUserDataFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'email': prefs.getString('email'),
      'fullName': prefs.getString('fullName'),
      'profileImage': prefs.getString('profileImage'),
      'nationalId': prefs.getString('nationalId'),
      'phoneNumber': prefs.getString('phoneNumber'),
      'password': prefs.getString('password'),
    };
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> updateUser(UserData updatedUser) async {
    try {
      final response = await _authService.updateUser(updatedUser);
      if (response != null) {
        _user = response;
        print(
            'Successful update profile: ${response.fullName}, Email: ${response.email}'); // Detailed print

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Failed to update profile: $error');
      return false;
    }
  }
}
