import 'app_localizations.dart';
import 'enums.dart';
import 'package:flutter/material.dart';

class Validator {
  static String? validate(
    String? text,
    ValidationState state,
    BuildContext context,
  ) {
    if (text == null || text.trim().isEmpty) {
      return _requiredFieldMessage(state, context);
    }

    switch (state) {
      case ValidationState.email:
        return _validateEmail(text, context);
      case ValidationState.phoneNumber:
        return _validatePhoneNumber(text, context);
      case ValidationState.password:
        return _validatePassword(text, context);
      case ValidationState.price:
        return _validatePrice(text, context);
      case ValidationState.normal:
    }
    return null;
  }

  static String? _validateEmail(String text, BuildContext context) {
    const emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    final emailRegex = RegExp(emailPattern);

    if (!emailRegex.hasMatch(text)) {
      return 'invalid_email_format'.tr(context);
    }
    return null;
  }

  static String? _validatePhoneNumber(String text, BuildContext context) {
    const phonePattern = r'^09\d{8}$';
    final phoneRegex = RegExp(phonePattern);

    if (!phoneRegex.hasMatch(text)) {
      return 'invalid_phone_format_09'.tr(context);
    }
    return null;
  }

  static String? _validatePassword(String text, BuildContext context) {
    if (text.length < 8) {
      return 'password_min_length_8'.tr(context);
    }
    return null;
  }

  static String? _validatePrice(String text, BuildContext context) {
    final price = double.tryParse(text);

    if (price == null) {
      return 'enter_valid_number'.tr(context);
    } else if (price <= 0) {
      return 'price_must_be_greater_than_zero'.tr(context);
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? confirmPassword,
    String? originalPassword,
    BuildContext context,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return 'please_confirm_password'.tr(context);
    }
    if (confirmPassword != originalPassword) {
      return 'passwords_do_not_match'.tr(context);
    }
    return null;
  }

  static String? _requiredFieldMessage(
    ValidationState state,
    BuildContext context,
  ) {
    return 'this_field_is_required'.tr(context);
  }
}
