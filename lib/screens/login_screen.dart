import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController targetPhoneC = TextEditingController(); // Naya Controller

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RSM WhatsApp Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400), // Web/Desktop ke liye width limit
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: phoneC,
                decoration: InputDecoration(
                  labelText: "Your Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 15),
              // --- YE NAYA FIELD HAI ---
              TextField(
                controller: targetPhoneC,
                decoration: InputDecoration(
                  labelText: "Target Phone Number (Talking to)",
                  hintText: "e.g. 9876543210",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message_outlined),
                  fillColor: Colors.teal.withOpacity(0.05),
                  filled: true,
                ),
              ),
              SizedBox(height: 25),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                ),
                onPressed: () async {
                  if (nameC.text.isEmpty || phoneC.text.isEmpty || targetPhoneC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields!")),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    final user = await ApiService.register(nameC.text, phoneC.text);
                    if (user != null) {
                      print("Login Success for: ${user.name}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            myPhone: phoneC.text,
                            targetPhone: targetPhoneC.text, // Dynamic target pass ho raha hai
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print("Login Error: $e");
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: Text("Start Chatting", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}