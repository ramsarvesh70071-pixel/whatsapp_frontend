import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameC;
  late TextEditingController aboutC;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.user.name);
    aboutC = TextEditingController(text: "Hey there! I am using RSM WhatsApp");
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _saveProfile() async {
    bool success = await ApiService.updateProfile(
        widget.user.phoneNumber,
        nameC.text,
        aboutC.text,
        _image?.path // Asli app mein yahan URL jayega upload ke baad
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), backgroundColor: Colors.teal.shade800),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.person, size: 70) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            TextField(
              controller: nameC,
              decoration: InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person)),
            ),
            SizedBox(height: 15),
            TextField(
              controller: aboutC,
              decoration: InputDecoration(labelText: "About", prefixIcon: Icon(Icons.info_outline)),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _saveProfile,
              child: Text("SAVE", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}