import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText; // Added to handle password visibility

  const CustomTextField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        // Light grey for hint text
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),

        // Default Border (Unfocused)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: AppColors.primaryTwoColors.withValues(
              alpha: 0.5,
            ), // Light Teal Border
            width: 1.5,
          ),
        ),

        // Border when typing (Focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: AppColors.primaryColors, // Darker Teal when active
            width: 2.0,
          ),
        ),

        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 24.0,
        ),

        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey.withValues(alpha: 0.5))
            : null,
      ),
    );
  }
}
