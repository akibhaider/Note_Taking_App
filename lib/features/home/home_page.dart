import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_provider.dart';
import '../font/font_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final List<double> fontSizes = [12, 14, 16, 18, 20];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final fontSizeState = ref.watch(fontSizeProvider);

    String fontLabel(double value) => sizeNameFromValue(value).label;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Font Size',
            onSelected: (value) {
              ref.read(fontSizeProvider.notifier).setFontSize(value);
            },
            itemBuilder: (context) => [
              for (final size in fontSizes)
                PopupMenuItem(
                  value: size,
                  child: Row(
                    children: [
                      Text(
                        fontLabel(size),
                        style: TextStyle(
                          fontSize: size,
                          fontWeight: size == fontSizeState.value ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (size == fontSizeState.value)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                )
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome to Notes App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Create and manage your notes easily',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/view-notes');
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Notes'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/create-note');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Note'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
