import 'package:ease_insurance_app/views/userProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/InsuranceData.dart';
import '../network/insurance_service.dart';
import 'AddInsurancePage.dart';
import 'InsuranceEditPage.dart';
import 'PremiumCalculationPage.dart';

class InsuranceListScreen extends StatefulWidget {
  final String userId;

  InsuranceListScreen({required this.userId}); // Constructor to receive userId

  @override
  _InsuranceListScreenState createState() => _InsuranceListScreenState();
}
class _InsuranceListScreenState extends State<InsuranceListScreen> {
  Future<List<Insurance>>? _insuranceList;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchInsurance();
  }

  Future<void> _loadUserIdAndFetchInsurance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null) {
      int userIdInt = int.parse(_userId!);
      setState(() {
        _insuranceList = InsuranceService().getInsurancesForUser(userIdInt);
      });
    } else {
      print('User ID not found in SharedPreferences');
      setState(() {
        _insuranceList = Future.value([]);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PremiumCalculationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: _userId.toString(),)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Insurance>>(
        future: _insuranceList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error state
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No insurance data available')); // No data state
          } else {
            final insurances = snapshot.data!;
            return ListView.builder(
              itemCount: insurances.length,
              itemBuilder: (context, index) {
                final insurance = insurances[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(insurance.insuranceName ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Country: ${insurance.country ?? 'Unknown'}'),
                        Text('Hospitals: ${insurance.hospitals.isNotEmpty ? insurance.hospitals.join(', ') : 'No Hospitals'}'),
                        Text('Annual Price: KES ${insurance.annualPrice?.toStringAsFixed(2) ?? 'N/A'}'),
                      ],
                    ),
                    onTap: () async {
                      final updatedInsurance = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InsuranceEditScreen(insurance: insurance),
                        ),
                      );

                      if (updatedInsurance != null) {
                        setState(() {
                          insurances[index] = updatedInsurance; // Update the list with new details
                        });
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newInsurance = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsuranceAddScreen(userId: _userId!), // Use _userId from SharedPreferences
            ),
          );

          if (newInsurance != null) {
            // Refresh the list after adding a new insurance
            _loadUserIdAndFetchInsurance();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Insurance',
      ),
    );
  }
}
