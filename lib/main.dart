import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.teal),
    home: LoginScreen(),
  ));
}