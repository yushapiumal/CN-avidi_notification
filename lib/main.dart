
import 'package:avidi_notification/pages/auth/login.dart';
import 'package:avidi_notification/pages/home/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AvidiNotify());
}

class AvidiNotify extends StatelessWidget {
  const AvidiNotify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avidi notification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  LoginScreen(), 
    );
  }
}