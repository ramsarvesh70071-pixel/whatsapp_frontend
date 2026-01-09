import 'package:flutter/material.dart';
// Aliases for conflict resolution
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:fast_contacts/fast_contacts.dart' as fast;

import 'chat_screen.dart';
import '../services/phone_contact_service.dart';

class ContactsScreen extends StatefulWidget {
  final String myPhone;
  const ContactsScreen({Key? key, required this.myPhone}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<fast.Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  _fetchContacts() async {
    final contacts = await PhoneContactService.getPhoneContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  // --- FEATURE 1: ADD CONTACT DIALOG ---
  void _showAddContactDialog() {
    TextEditingController nameC = TextEditingController();
    TextEditingController phoneC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(hintText: "Name")),
            TextField(controller: phoneC, decoration: const InputDecoration(hintText: "Phone"), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                if (nameC.text.isNotEmpty && phoneC.text.isNotEmpty) {
                  await PhoneContactService.saveContactToPhone(nameC.text, phoneC.text);
                  Navigator.pop(context);
                  _fetchContacts();
                }
              },
              child: const Text("Save")
          ),
        ],
      ),
    );
  }

  // --- FEATURE 2: OPTIONS MENU (EDIT/DELETE) ---
  void _showOptionsDialog(BuildContext context, String phone, String currentName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1f2c34),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text("Edit Name", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showEditDialog(phone, currentName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Contact", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await PhoneContactService.deleteContact(phone);
              _fetchContacts(); // Refresh list
            },
          ),
        ],
      ),
    );
  }

  // --- FEATURE 3: EDIT DIALOG ---
  void _showEditDialog(String phone, String oldName) {
    TextEditingController editC = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Contact"),
        content: TextField(controller: editC, decoration: const InputDecoration(hintText: "New Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await PhoneContactService.updateContactName(phone, editC.text);
              Navigator.pop(context);
              _fetchContacts();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121b22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1f2c34),
        title: const Text("Select contact", style: TextStyle(color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00a884),
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => _showAddContactDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00a884)))
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];

          final phone = contact.phones.isNotEmpty ? contact.phones[0] : "No number";
          final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade700,
              child: const Icon(Icons.person, color: Colors.white70),
            ),
            title: Text(
                contact.displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
            ),
            subtitle: Text(phone, style: const TextStyle(color: Colors.grey)),

            // --- LONG PRESS FUNCTIONALITY ADDED ---
            onLongPress: () => _showOptionsDialog(context, cleanPhone, contact.displayName),

            onTap: () {
              if (cleanPhone.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                  myPhone: widget.myPhone,
                  targetPhone: cleanPhone,
                  targetName: contact.displayName,
                )));
              }
            },
          );
        },
      ),
    );
  }
}