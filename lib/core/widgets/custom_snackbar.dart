import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color(0xFF4CAF50), // أخضر افتراضي
    IconData icon = Icons.check_circle_outline,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // يجعلها تطفو
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        backgroundColor: Colors.transparent, // الخلفية شفافة
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
