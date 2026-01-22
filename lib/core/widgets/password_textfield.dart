import 'package:flutter/material.dart';

import '../utils/colors.dart';

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
      obscureText: !_isPasswordVisible,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColors.textFieldColor),
        filled: true,
        fillColor: AppColors.textFieldColor.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textFieldColor,
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
