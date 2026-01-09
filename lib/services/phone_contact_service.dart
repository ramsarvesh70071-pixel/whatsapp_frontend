import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneContactService {
  // 1. Saare Contacts (SIM + Phone) Fetch karna
  static Future<List<Contact>> getPhoneContacts() async {
    if (await Permission.contacts.request().isGranted) {
      // withProperties: true zaroori hai phone number lene ke liye
      return await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
    }
    return [];
  }

  // 2. Naya Contact Save karna
  static Future<void> saveContact(String name, String phone) async {
    if (await Permission.contacts.request().isGranted) {
      final newContact = Contact()
        ..name.first = name
        ..phones = [Phone(phone)];
      await newContact.insert();
    }
  }

  // 3. Contact Delete karna
  static Future<void> deleteContact(Contact contact) async {
    await contact.delete();
  }
}