import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: widget.hintText,
        // Style copied from CustomTextField
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),

        // Default Border (Unfocused)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide(
            color: AppColors.primaryTwoColors.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),

        // Border when typing (Focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide(color: AppColors.primaryColors, width: 2.0),
        ),

        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        // Focused Error Border (Good practice to add to match behavior)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),

        // Password Visibility Toggle
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            // Match the grey color from CustomTextField icon style
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
