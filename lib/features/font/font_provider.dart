import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StateNotifier to manage font size state with persistence
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0) {
    _loadFontSize();
  }

  // Load font size from SharedPreferences
  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble('fontSize') ?? 16.0;
    if (mounted) {
      state = size;
    }
  }

  // Set a specific font size (must be between 12.0 and 20.0)
  Future<void> setFontSize(double size) async {
    if (size >= 12.0 && size <= 20.0) {
      state = size;
      await _saveFontSize();
    }
  }

  // Increase font size by 1.0 (max 20.0)
  Future<void> increaseFontSize() async {
    if (state < 20.0) {
      state += 1.0;
      await _saveFontSize();
    }
  }

  // Decrease font size by 1.0 (min 12.0)
  Future<void> decreaseFontSize() async {
    if (state > 12.0) {
      state -= 1.0;
      await _saveFontSize();
    }
  }

  // Save font size to SharedPreferences
  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', state);
  }
}

// Provider that exposes the font size state
// This can be watched in widgets using: ref.watch(fontSizeProvider)
// Returns a double value representing the current font size
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});