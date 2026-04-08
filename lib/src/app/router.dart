import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
import 'package:absensi_go/src/features/check_in/presentation/check_in.dart';
import 'package:absensi_go/src/features/check_out/presentation/check_out.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/izin/presentation/izin_list_screen.dart';
import 'package:absensi_go/src/features/splash/splashscreen.dart';
import 'package:absensi_go/src/features/izin/presentation/izin_detail_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// router.dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final token = await ref.read(localStorageProvider).getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isOnAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/splash';

      // Belum login dan bukan di halaman auth → ke login
      if (!isLoggedIn && !isOnAuth) return '/login';

      // Sudah login tapi masih di halaman auth → ke home
      if (isLoggedIn && isOnAuth) return '/main';

      return null; // lanjut normal
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/main', builder: (context, state) => const Homescreen()),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckOutScreen(),
      ),
      // Izin routes
      GoRoute(
        path: '/izin',
        builder: (context, state) => const IzinListScreen(),
      ),
    ],
  );
});
