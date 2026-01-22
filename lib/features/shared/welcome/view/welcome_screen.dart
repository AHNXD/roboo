import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static const String routeName = "/welcome";
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(child: Container())),
    );
  }
}
