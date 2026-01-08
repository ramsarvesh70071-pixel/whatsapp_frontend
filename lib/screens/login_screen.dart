import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'user_list_screen.dart'; // Iska code niche Step 3 mein hai

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("RSM WhatsApp Login"), centerTitle: true, backgroundColor: Colors.teal),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat, size: 80, color: Colors.teal),
              SizedBox(height: 30),
              TextField(
                controller: nameC,
                decoration: InputDecoration(labelText: "Your Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),
              SizedBox(height: 15),
              TextField(
                controller: phoneC,
                decoration: InputDecoration(labelText: "Your Phone Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 25),
              isLoading
                  ? CircularProgressIndicator(color: Colors.teal)
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.teal),
                onPressed: () async {
                  if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields!")));
                    return;
                  }

                  setState(() => isLoading = true);
                  try {
                    // Backend par user register/login karein
                    final UserModel? user = await ApiService.register(nameC.text.trim(), phoneC.text.trim());

                    if (user != null) {
                      // Login ke baad Seedhe User List par jayein
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => UserListScreen(currentUser: user)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: Text("Login & Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}