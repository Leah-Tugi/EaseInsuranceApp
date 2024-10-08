import 'package:flutter/material.dart';

import '../models/InsuranceData.dart';

class PremiumReportScreen extends StatelessWidget {
  final Insurance insurance;
  final int monthsCovered;
  final double calculatedPremium;

  PremiumReportScreen({
    required this.insurance,
    required this.monthsCovered,
    required this.calculatedPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Calculation Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insurance Cover: ${insurance.insuranceName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Country: ${insurance.country}'),
            Text('Hospitals Covered: ${insurance.hospitals.join(', ')}'),
            Text('Annual Price: KES ${insurance.annualPrice?.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text(
              'Months Covered: $monthsCovered',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Calculated Premium: KES ${calculatedPremium.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
