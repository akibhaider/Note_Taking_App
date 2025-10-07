import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'features/theme/theme_provider.dart';
import 'features/font/font_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeProvider);
    final fontSizeState = ref.watch(fontSizeProvider); // FontSizeState (has .value and .name)

    return MaterialApp.router(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSizeState.value),
          bodyMedium: TextStyle(fontSize: fontSizeState.value),
          titleLarge: TextStyle(fontSize: fontSizeState.value + 4),
          titleMedium: TextStyle(fontSize: fontSizeState.value + 2),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSizeState.value),
          bodyMedium: TextStyle(fontSize: fontSizeState.value),
          titleLarge: TextStyle(fontSize: fontSizeState.value + 4),
          titleMedium: TextStyle(fontSize: fontSizeState.value + 2),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
