import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/presentation/register_view.dart';
import 'package:absensi_go/src/features/splash/splashscreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/main', builder: (context, state) => const Homescreen()),
    ],
  );
});
