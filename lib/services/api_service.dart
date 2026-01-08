import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = "https://ram-backend-ipu1.onrender.com/api";

  // 1. Register User
  static Future<UserModel?> register(String name, String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phoneNumber": phone}),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Network Error in register: $e");
    }
    return null;
  }

  // 2. Fetch All Registered Users (For User List)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((user) => UserModel.fromJson(user)).toList();
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
    return [];
  }

  // 3. Fetch Chat History (For Message Persistence)
  static Future<List<dynamic>> getChatHistory(String senderId, String recipientId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/messages/$senderId/$recipientId"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // List of messages
      }
    } catch (e) {
      print("Error fetching history: $e");
    }
    return [];
  }
}