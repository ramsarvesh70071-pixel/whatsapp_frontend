import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8080/api";// For Android Emulator

  static Future<UserModel?> register(String name, String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phoneNumber": phone}),
      );

      print("Response Status: ${response.statusCode}"); // Debugging ke liye
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Network Error: $e");
    }
    return null;
  }
}