import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for font size names
enum FontSizeName {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}

// Extension to convert enum to string
extension FontSizeNameExtension on FontSizeName {
  String get label {
    switch (this) {
      case FontSizeName.extraSmall:
        return "Extra Small";
      case FontSizeName.small:
        return "Small";
      case FontSizeName.medium:
        return "Medium";
      case FontSizeName.large:
        return "Large";
      case FontSizeName.extraLarge:
        return "Extra Large";
    }
  }
}

// Data class for font size state
class FontSizeState {
  final double value;
  final FontSizeName name;

  FontSizeState({required this.value, required this.name});
}

// Map font size values to names
FontSizeName sizeNameFromValue(double value) {
  if (value <= 12.0) return FontSizeName.extraSmall;
  if (value <= 14.0) return FontSizeName.small;
  if (value <= 16.0) return FontSizeName.medium;
  if (value <= 18.0) return FontSizeName.large;
  return FontSizeName.extraLarge;
}

// StateNotifier with named font sizes
class FontSizeNotifier extends StateNotifier<FontSizeState> {
  FontSizeNotifier()
      : super(FontSizeState(value: 16.0, name: sizeNameFromValue(16.0))) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble('fontSize') ?? 16.0;
    if (mounted) {
      state = FontSizeState(value: size, name: sizeNameFromValue(size));
    }
  }

  Future<void> setFontSize(double newSize) async {
    double size = newSize.clamp(12.0, 20.0); // Clamp to allowed range
    state = FontSizeState(value: size, name: sizeNameFromValue(size));
    await _saveFontSize();
  }

  Future<void> increaseFontSize() async {
    double nextSize = (state.value + 2.0).clamp(12.0, 20.0);
    state = FontSizeState(value: nextSize, name: sizeNameFromValue(nextSize));
    await _saveFontSize();
  }

  Future<void> decreaseFontSize() async {
    double nextSize = (state.value - 2.0).clamp(12.0, 20.0);
    state = FontSizeState(value: nextSize, name: sizeNameFromValue(nextSize));
    await _saveFontSize();
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', state.value);
  }
}

// Provider to expose FontSizeState (value + name)
final fontSizeProvider =
StateNotifierProvider<FontSizeNotifier, FontSizeState>((ref) {
  return FontSizeNotifier();
});
