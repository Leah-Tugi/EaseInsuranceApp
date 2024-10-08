import 'package:ease_insurance_app/viewmodels/AuthViewModel.dart';
import 'package:ease_insurance_app/views/InsuranceListPage.dart';
import 'package:ease_insurance_app/views/LoginPage.dart';
import 'package:ease_insurance_app/views/RegistrationPage.dart';
import 'package:ease_insurance_app/views/SplashScreen.dart'; // Import SplashScreen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add any other providers here as needed
      ],
      child: EaseInsuranceApp(),
    ),
  );
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class EaseInsuranceApp extends StatelessWidget {
  final Color _primaryColor = HexColor('#DC54FE'); // Primary color
  final Color _accentColor = HexColor('#0000FF'); // Accent color

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ease Insurance',
      theme: ThemeData(
        primaryColor: _primaryColor,
        hintColor: _accentColor,
        scaffoldBackgroundColor: Colors.grey.shade100,
        primarySwatch: Colors.blue, // Default primary swatch color
      ),
      initialRoute: '/', // Start with the splash screen
      routes: {
        '/': (context) => SplashScreen(), // Set SplashScreen as the initial screen
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/insuranceList': (context) => InsuranceListScreen(userId: '_',), // Add route for insurance list
      },
    );
  }
}
