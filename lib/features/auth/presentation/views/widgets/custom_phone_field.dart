// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../../core/utils/constats.dart';

class CustomPhoneField extends StatefulWidget {
  const CustomPhoneField(
      {super.key, required this.controller, required this.text});
  final PhoneController controller;
  final String text;
  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  final FocusNode fNode = FocusNode();
  bool isFill = true;
  Color fillColor = const Color(0xffF4F7FE);
  Color textColor = Colors.black87;
  Color labelTextColor = Colors.grey;
  @override
  void initState() {
    fNode.addListener(() {
      if (fNode.hasFocus) {
        setState(() {
          fillColor = Colors.transparent;
          labelTextColor = Colors.white;

          textColor = Colors.white;
        });
      } else {
        setState(() {
          fillColor = const Color(0xffF4F7FE);

          labelTextColor = Colors.grey;
          textColor = Colors.black87;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(kBorderRadius)),
        padding: EdgeInsets.only(top: 8),
        margin: EdgeInsets.symmetric(vertical: 16),
        child: PhoneFormField(
          controller: widget.controller,
          focusNode: fNode,
          countrySelectorNavigator: CountrySelectorNavigator.dialog(),
          countryButtonStyle: CountryButtonStyle(
            showDialCode: true,
            showIsoCode: true,
            showFlag: false,
            textStyle: TextStyle(color: labelTextColor),
          ),
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffB2B9C6)),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            labelStyle: TextStyle(color: labelTextColor),
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xffB2B9C6)),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            filled: true,
            fillColor: fillColor,
            labelText: widget.text,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
                borderSide: BorderSide.none),
          ),
          validator: PhoneValidator.compose([
            PhoneValidator.required(context, errorText: "رقم الهاتف مطلوب"),
            PhoneValidator.validMobile(context, errorText: "رقم هاتف غير صالح"),
          ]),
          // onChanged: (phoneNumber) => log(
          //     "+${widget.controller.value.countryCode}${widget.controller.value.nsn}"),
        ),
      ),
    );
  }
}
