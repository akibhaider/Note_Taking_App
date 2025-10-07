import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database_provider.dart';
import '../../features/theme/theme_provider.dart';
import '../../features/font/font_provider.dart';

class CreateNotePage extends ConsumerStatefulWidget {
  final String? noteId;

  const CreateNotePage({super.key, this.noteId});

  @override
  ConsumerState<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends ConsumerState<CreateNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  static final List<double> fontSizes = [12, 14, 16, 18, 20];

  String fontLabel(double val) => sizeNameFromValue(val).label;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final repository = await ref.read(notesRepositoryProvider.future);
      final note = await repository.getNoteById(widget.noteId!);

      if (note != null && mounted) {
        _titleController.text = note.title;
        _contentController.text = note.content;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = await ref.read(notesRepositoryProvider.future);
      final now = DateTime.now();

      if (widget.noteId == null) {
        final note = Note(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repository.createNote(note);
      } else {
        final existingNote = await repository.getNoteById(widget.noteId!);
        if (existingNote != null) {
          final updatedNote = existingNote.copyWith(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            updatedAt: now,
          );
          await repository.updateNote(updatedNote);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.noteId == null ? 'Note created!' : 'Note updated!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final fontSizeState = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Create Note' : 'Edit Note'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          // Font size selector
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
                )
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  style: TextStyle(
                    fontSize: fontSizeState.value,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter your note here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  style: TextStyle(fontSize: fontSizeState.value),
                  maxLines: null,
                  minLines: 15,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveNote,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Note'),
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
      ),
    );
  }
}
