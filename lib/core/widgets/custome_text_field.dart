import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textFieldColor),
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppColors.textFieldColor)
            : null,
      ),
    );
  }
}
