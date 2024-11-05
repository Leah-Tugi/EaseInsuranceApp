import 'dart:convert';
import 'package:ease_insurance_app/models/UserData.dart';
import 'package:http/http.dart' as http;


class AuthService {
  final String baseUrl = 'https://6703f084ab8a8f8927324c50.mockapi.io/api/v1/users';

  Future<UserData?> loginUser(String email, String password) async {
    final response = await http.get(Uri.parse('$baseUrl?email=$email&password=$password'));

    if (response.statusCode == 200) {
      final List users = json.decode(response.body);
      if (users.isNotEmpty) {
        return UserData.fromJson(users[0]);
      }
    }
    return null;
  }

  Future<UserData?> registerUser(UserData user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return UserData.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<UserData?> updateUser(UserData user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${user.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );
      if (response.statusCode == 200) {
        return UserData.fromJson(json.decode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Failed to update user: $e');
      return null;
    }
  }

}
