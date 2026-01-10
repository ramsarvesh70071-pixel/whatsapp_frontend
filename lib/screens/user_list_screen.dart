import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; // Is file ko create karna hoga jo maine pehle di thi

class UserListScreen extends StatefulWidget {
  final UserModel currentUser;
  UserListScreen({required this.currentUser});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String searchQuery = "";
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search contacts...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => searchQuery = val),
        )
            : Text("RSM WhatsApp", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              isSearching = !isSearching;
              if (!isSearching) searchQuery = "";
            }),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.currentUser)
                ));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text("Profile")),
              PopupMenuItem(value: 'settings', child: Text("Settings")),
              PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: ApiService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No contacts found"));

          // Filter: Apne aap ko hatayein aur Search filter lagayein
          final users = snapshot.data!.where((u) {
            bool isNotMe = u.phoneNumber != widget.currentUser.phoneNumber;
            bool matchesSearch = u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                u.phoneNumber.contains(searchQuery);
            return isNotMe && matchesSearch;
          }).toList();

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
        onPressed: () => setState(() {}),
        backgroundColor: Colors.teal.shade800,
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}