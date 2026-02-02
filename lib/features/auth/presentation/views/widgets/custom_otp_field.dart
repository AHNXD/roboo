import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:roboo/core/utils/colors.dart';

class CustomOtpFields extends StatelessWidget {
  const CustomOtpFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 65,
          height: 65,
          child: TextFormField(
            onChanged: (value) {
              // Auto-focus logic
              if (value.length == 1) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty) {
                FocusScope.of(context).previousFocus();
              }
            },
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColors,
              fontFamily: 'Cairo', // Or your default font
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            // Limit to 1 digit
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),

              // Default Border (Teal Thin)
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.primaryColors.withOpacity(0.5),
                  width: 1.5,
                ),
              ),

              // Focused Border (Teal Thick)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: AppColors.primaryColors,
                  width: 2.0,
                ),
              ),

              // Error/Other states can be added here
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      }),
    );
  }
}
