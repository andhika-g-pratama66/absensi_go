import 'package:absensi_go/src/core/constants/app_colors.dart';
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

InputDecoration modernInputDecoration({
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? hintText,
  String? labelText,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: AppColors.labelText, fontSize: 14),
    prefixIcon: prefixIcon != null
        ? IconTheme(
            data: const IconThemeData(color: AppColors.labelText, size: 18),
            child: prefixIcon,
          )
        : null,
    suffixIcon: suffixIcon,
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
    filled: true,
    fillColor: AppColors.inputBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBg, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}
