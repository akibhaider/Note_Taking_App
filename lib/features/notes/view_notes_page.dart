import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database_provider.dart';
import '../../features/theme/theme_provider.dart';
import '../../features/font/font_provider.dart';

class ViewNotesPage extends ConsumerWidget {
  const ViewNotesPage({super.key});

  static final List<double> fontSizes = [12, 14, 16, 18, 20];
  String fontLabel(double val) => sizeNameFromValue(val).label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesListProvider);
    final isDarkMode = ref.watch(themeProvider);
    final fontSizeState = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                  child: Text(
                    fontLabel(size),
                    style: TextStyle(
                      fontSize: size,
                      fontWeight: size == fontSizeState.value ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: notesAsyncValue.when(
          data: (notes) {
            if (notes.isEmpty) {
              return _buildEmptyState(context, fontSizeState);
            }
            return _buildNotesList(context, notes, fontSizeState);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-note'),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, fontSizeState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No notes yet',
              style: TextStyle(
                fontSize: fontSizeState.value + 4,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button below to create your first note',
              style: TextStyle(fontSize: fontSizeState.value, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes, fontSizeState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/create-note?id=${note.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: fontSizeState.value + 2,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),

                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: TextStyle(fontSize: fontSizeState.value, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(fontSize: fontSizeState.value - 2, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Just now';
        return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
