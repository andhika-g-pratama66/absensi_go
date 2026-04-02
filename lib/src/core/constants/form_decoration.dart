import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:flutter/material.dart';

InputDecoration formInputConstant({
  String? hintText,
  Widget? prefixIconData,
  Widget? prefixWidget,
  String? labelText,
  Widget? suffixIconData,
  Color? fillColor,
  bool? filled,
  String? suffixText,
  String? prefixText,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

    filled: filled,
    hintText: hintText,
    labelText: labelText,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    prefixIcon: prefixIconData,
    suffixIcon: suffixIconData,
    suffixText: suffixText,
    floatingLabelStyle: DefaultFont.bodyBold,
    prefixText: prefixText,
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    fillColor: fillColor,

    prefixStyle: TextStyle(),
    prefix: prefixWidget,
  );
}
