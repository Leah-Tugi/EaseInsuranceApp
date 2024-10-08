import 'package:flutter/material.dart';

import '../models/InsuranceData.dart';
import '../network/insurance_service.dart';
import 'PremiumReportPage.dart';

class PremiumCalculationScreen extends StatefulWidget {
  @override
  _PremiumCalculationScreenState createState() => _PremiumCalculationScreenState();
}

class _PremiumCalculationScreenState extends State<PremiumCalculationScreen> {
  List<Insurance> _insurances = [];
  Insurance? _selectedInsurance;
  final TextEditingController _monthsController = TextEditingController();
  double? _calculatedPremium;

  @override
  void initState() {
    super.initState();
    _fetchInsurances();
  }

  Future<void> _fetchInsurances() async {
    try {
      _insurances = await InsuranceService().getInsurances();
    } catch (e) {
      // Handle any errors that occur during data fetching
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching insurance data: $e')),
      );
    } finally {
      setState(() {});
    }
  }

  void _calculatePremium() {
    if (_selectedInsurance != null && _monthsController.text.isNotEmpty) {
      int monthsCovered = int.tryParse(_monthsController.text) ?? 0;

      if (monthsCovered <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid number of months')),
        );
        return;
      }

      _calculatedPremium = _selectedInsurance!.annualPrice! * monthsCovered / 12; // Calculate premium
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PremiumReportScreen(
            insurance: _selectedInsurance!,
            monthsCovered: monthsCovered,
            calculatedPremium: _calculatedPremium!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an insurance cover and enter the months')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculate Premium'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Insurance>(
              hint: Text('Select Insurance Cover'),
              value: _selectedInsurance,
              onChanged: (Insurance? newValue) {
                setState(() {
                  _selectedInsurance = newValue;
                  _calculatedPremium = null; // Reset calculated premium
                });
              },
              items: _insurances.map((insurance) {
                return DropdownMenuItem(
                  value: insurance,
                  child: Text(insurance.insuranceName!), // Updated to insuranceName
                );
              }).toList(),
            ),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Months Covered'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculatePremium,
              child: Text('Calculate Premium'),
            ),
            if (_calculatedPremium != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Calculated Premium: KES ${_calculatedPremium!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            if (_insurances.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'No insurance covers available. Please add some.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
