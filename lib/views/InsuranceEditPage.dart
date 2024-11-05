import 'package:flutter/material.dart';

import '../models/InsuranceData.dart';
import '../network/insurance_service.dart';

class InsuranceEditScreen extends StatefulWidget {
  final Insurance insurance;

  InsuranceEditScreen({required this.insurance});

  @override
  _InsuranceEditScreenState createState() => _InsuranceEditScreenState();
}

class _InsuranceEditScreenState extends State<InsuranceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _hospitalsController;
  late TextEditingController _annualPriceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.insurance.insuranceName);
    _countryController = TextEditingController(text: widget.insurance.country);
    _hospitalsController = TextEditingController(text: widget.insurance.hospitals.join(', '));
    _annualPriceController = TextEditingController(text: widget.insurance.annualPrice.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _hospitalsController.dispose();
    _annualPriceController.dispose();
    super.dispose();
  }

  Future<void> _updateInsurance() async {
    if (_formKey.currentState!.validate()) {
      try {
        double annualPrice = double.parse(_annualPriceController.text);
        Insurance updatedInsurance = Insurance(
          id: widget.insurance.id,
          insuranceName: _nameController.text,
          country: _countryController.text,
          hospitals: _hospitalsController.text.split(', '),
          annualPrice: annualPrice,
          userId: widget.insurance.userId,
          createdAt: widget.insurance.createdAt,
        );

        await InsuranceService().updateInsurance(updatedInsurance);
        Navigator.pop(context, updatedInsurance);
      } catch (e) {
        // Show an error message if parsing fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid annual price. Please enter a valid number.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Insurance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Insurance Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) => value!.isEmpty ? 'Please enter a country' : null,
              ),
              TextFormField(
                controller: _hospitalsController,
                decoration: InputDecoration(labelText: 'Hospitals Covered'),
                validator: (value) => value!.isEmpty ? 'Please enter hospitals' : null,
              ),
              TextFormField(
                controller: _annualPriceController,
                decoration: InputDecoration(labelText: 'Annual Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateInsurance,
                child: Text('Update Insurance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
