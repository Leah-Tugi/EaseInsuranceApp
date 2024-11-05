import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/InsuranceData.dart';

class InsuranceService {
  final String baseUrl = 'https://6703f084ab8a8f8927324c50.mockapi.io/api/v1/insurance';

  Future<void> addInsurance(Insurance insurance) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(insurance.toJson()),
    );

    // Log the request and response
    print('POST Request URL: $baseUrl');
    print('Request Body: ${json.encode(insurance.toJson())}');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {

      print('Insurance added successfully');
    } else {
      print('Failed to add insurance');
    }
  }

  Future<List<Insurance>> getInsurancesForUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));

    print('GET Request URL: $baseUrl?userId=$userId');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((insurance) => Insurance.fromJson(insurance)).toList();
    } else {
      throw Exception('Failed to load insurances for user $userId');
    }
  }



  Future<List<Insurance>> getInsurances() async {
    final response = await http.get(Uri.parse(baseUrl));

    // Log the request and response
    print('GET Request URL: $baseUrl');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((insurance) => Insurance.fromJson(insurance)).toList();
    }
    return [];
  }

  Future<void> updateInsurance(Insurance insurance) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${insurance.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': insurance.insuranceName,
        'country': insurance.country,
        'hospitals': insurance.hospitals,
        'annualPrice': insurance.annualPrice,
      }),
    );


    print('PUT Request URL: $baseUrl/${insurance.id}');
    print('Request Body: ${json.encode({
      'name': insurance.insuranceName,
      'country': insurance.country,
      'hospitals': insurance.hospitals,
      'annualPrice': insurance.annualPrice,
    })}');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update insurance');
    }
  }
}
