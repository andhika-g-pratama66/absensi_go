import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF1A1A2E).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child:
                    authState.whenOrNull(
                      data: (user) {
                        final name = user?.data?.user?.name ?? '';
                        final parts = name.trim().split(' ');
                        final initials = parts.length >= 2
                            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                            : name.isNotEmpty
                            ? name[0].toUpperCase()
                            : 'U';
                        return Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                        );
                      },
                    ) ??
                    const Text('U', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 12),
            authState.whenOrNull(
                  data: (user) => Text(
                    user?.data?.user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ) ??
                const SizedBox(),
            const SizedBox(height: 4),
            authState.whenOrNull(
                  data: (user) => Text(
                    user?.data?.user?.email ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ) ??
                const SizedBox(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.pushReplacement(const LoginScreen());
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFAECE7),
                  foregroundColor: const Color(0xFF993C1D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
