import 'package:flutter/material.dart';

class AppButtonStyles {
  static final _baseShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  static const _defaultSize = Size(double.maxFinite, 56);

  static ButtonStyle defaultButton() {
    return ElevatedButton.styleFrom(fixedSize: _defaultSize, shape: _baseShape);
  }
}
