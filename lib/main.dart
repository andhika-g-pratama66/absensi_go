import 'package:absensi_go/src/app/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_file.dart';

void main() async {
  runApp(ProviderScope(child: const AbsensiApp()));
}
