import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bottomNavIndexProvider =
    StateNotifierProvider<BottomNavIndexNotifier, int>((ref) {
      return BottomNavIndexNotifier();
    });

class BottomNavIndexNotifier extends StateNotifier<int> {
  BottomNavIndexNotifier() : super(0) {
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('navIndex') ?? 0;
    state = savedIndex;
  }

  Future<void> setIndex(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navIndex', index);
  }
}
