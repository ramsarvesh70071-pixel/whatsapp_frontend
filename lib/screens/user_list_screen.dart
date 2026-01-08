import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class UserListScreen extends StatefulWidget {
  final UserModel currentUser;
  UserListScreen({required this.currentUser});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RSM WhatsApp", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: ApiService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No contacts found"));

          // Filter: Apne aap ko list se hatayein
          final users = snapshot.data!.where((u) => u.phoneNumber != widget.currentUser.phoneNumber).toList();

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                  ),
                ),
                title: Text(
                  user.name == "User" ? "Contact: ${user.phoneNumber}" : user.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Hey there! I am using RSM WhatsApp", maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    myPhone: widget.currentUser.phoneNumber,
                    targetPhone: user.phoneNumber,
                    targetName: user.name,
                  )));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}), // Refresh list
        backgroundColor: Colors.teal.shade800,
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}