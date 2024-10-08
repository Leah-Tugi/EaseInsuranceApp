import 'package:flutter/material.dart';
import '../models/InsuranceData.dart';
import '../network/insurance_service.dart';
import '../utils/widgets/OutlineInputWidget.dart';

class InsuranceAddScreen extends StatefulWidget {
  final String userId;

  InsuranceAddScreen({required this.userId});

  @override
  _InsuranceAddScreenState createState() => _InsuranceAddScreenState();
}

class _InsuranceAddScreenState extends State<InsuranceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _hospitalsController;
  late TextEditingController _annualPriceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _countryController = TextEditingController();
    _hospitalsController = TextEditingController();
    _annualPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _hospitalsController.dispose();
    _annualPriceController.dispose();
    super.dispose();
  }

  Future<void> _addInsurance() async {
    if (_formKey.currentState!.validate()) {
      try {
        double annualPrice = double.parse(_annualPriceController.text);
        Insurance newInsurance = Insurance(
          id: widget.userId,
          insuranceName: _nameController.text,
          country: _countryController.text,
          hospitals: _hospitalsController.text.split(',').map((e) => e.trim()).toList(), // Trim spaces after commas
          annualPrice: annualPrice,
          userId: widget.userId,
          createdAt: DateTime.now(),
        );

        await InsuranceService().addInsurance(newInsurance);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insurance added successfully!')),
        );

        // Clear the form fields (optional)
        _formKey.currentState?.reset();

        // Go back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        // Show an error message if parsing or API call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add insurance. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Insurance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              OutlineInputWidget(
                controller: _nameController,
                label: 'Insurance Name',
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              OutlineInputWidget(
                controller: _countryController,
                label: 'Country',
                validator: (value) => value!.isEmpty ? 'Please enter a country' : null,
              ),
              OutlineInputWidget(
                controller: _hospitalsController,
                label: 'Hospitals Covered',
                validator: (value) => value!.isEmpty ? 'Please enter hospitals' : null,
              ),
              OutlineInputWidget(
                controller: _annualPriceController,
                label: 'Annual Price',
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
                onPressed: _addInsurance,
                child: Text('Add Insurance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
