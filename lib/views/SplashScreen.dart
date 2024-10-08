import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package

import 'InsuranceListPage.dart';
import 'LoginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate some initialization tasks (Splash screen display duration)
    await Future.delayed(const Duration(seconds: 3));

    // Check internet connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // Show a dialog or message to the user if no connection
      _showNoConnectionDialog();
      return; // Exit if there is no internet connection
    }

    // Check if user ID exists in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      // User is logged in, navigate to InsuranceListPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InsuranceListScreen(userId: userId),
        ),
      );
    } else {
      // No user ID found, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.approval, size: 100, color: Colors.blue), // Example logo
            SizedBox(height: 20),
            Text(
              'Welcome to EaseInsurance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
