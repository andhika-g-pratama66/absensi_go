import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/features/attendance/presentation/pages/history_page.dart';
import 'package:absensi_go/src/features/attendance/presentation/pages/home_page.dart';
import 'package:absensi_go/src/features/profile/presentation/pages/profile_page.dart';
import 'package:absensi_go/src/features/attendance/provider/bottom_nav_index_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';

import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  final List<Widget> _pages = const [HomePage(), RiwayatPage(), ProfilPage()];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ref.read(localStorageProvider).getToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      context.pushReplacement(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    ref.listen<AsyncValue<UserModel?>>(authProvider, (_, next) {
      next.whenData((user) {
        if (user == null && mounted) {
          context.pushReplacement(const LoginScreen());
        }
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: _BottomNavBar(currentIndex: currentIndex),
    );
  }
}

class _BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                ref,
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
              ),
              _navItem(
                ref,
                index: 1,
                icon: Icons.history_rounded,
                label: 'Riwayat',
              ),
              _navItem(
                ref,
                index: 2,
                icon: Icons.person_rounded,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    WidgetRef ref, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    const darkBg = Color(0xFF1A1A2E);
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? darkBg.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? darkBg : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? darkBg : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
