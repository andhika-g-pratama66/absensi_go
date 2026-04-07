import 'dart:developer';

import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/batch/provider/batch_provider.dart';
import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:absensi_go/src/features/training/provider/training_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single provider to handle all initialization logic for the app.
final appStartProvider = FutureProvider<void>((ref) async {
  log('[AppStartup] Initializing...');

  // 1. Initialize authentication state (from local storage)
  // This is critical for redirection, so we await it first.
  final user = await ref.read(authProvider.future);

  // 2. Pre-load other data in parallel (Non-critical)
  // We wrap them in try-catch so one failure doesn't stop the app from starting.
  final initializers = <Future>[];

  if (user != null) {
    log('[AppStartup] User logged in. Pre-loading data...');
    initializers.addAll([
      _safeInit(() => ref.read(authProvider.notifier).refreshUser(), 'UserRefresh'),
      // For AsyncNotifier, we just await the .future to trigger build()
      _safeInit(() => ref.read(checkInProvider.future), 'TodayCheckIn'),
      _safeInit(() => ref.read(checkOutProvider.future), 'TodayCheckOut'),
      _safeInit(() => ref.read(izinProvider.notifier).loadIzinList(), 'IzinList'),
    ]);
  }

  // Common metadata for everyone (useful for registration)
  initializers.addAll([
    _safeInit(() => ref.read(batchListProvider.future), 'BatchList'),
    _safeInit(() => ref.read(trainingListProvider.future), 'TrainingList'),
  ]);

  // Run all non-critical initializations in parallel
  await Future.wait(initializers);

  // 3. Mandatory delay for branding
  await Future.delayed(const Duration(seconds: 2));
  log('[AppStartup] Initialization complete.');
});

/// Helper to run an initialization task safely without breaking the whole startup
Future<void> _safeInit(Future<void> Function() task, String label) async {
  try {
    await task();
  } catch (e, stack) {
    log('[AppStartup] Error initializing $label: $e', stackTrace: stack);
    // We swallow the error here so other tasks can continue
  }
}
