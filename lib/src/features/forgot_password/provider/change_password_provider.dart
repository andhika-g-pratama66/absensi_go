import 'package:flutter_riverpod/legacy.dart';

final otpLoadingProvider = StateProvider<bool>((ref) => false);
final otpResendProvider = StateProvider<bool>((ref) => false);
final otpCountdownProvider = StateProvider<int>((ref) => 60);
final newPassLoadingProvider = StateProvider<bool>((ref) => false);
final showNewPassProvider = StateProvider<bool>((ref) => false);
final showConfirmPassProvider = StateProvider<bool>((ref) => false);
final fpLoadingProvider = StateProvider<bool>((ref) => false);
