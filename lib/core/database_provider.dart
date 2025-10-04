import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

part 'database_provider.g.dart';

// Note Model
class Note {
  final String? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Note to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Copy with method for updates
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Database provider
@riverpod
Future<Database> database(DatabaseRef ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  await appDir.create(recursive: true);
  final dbPath = join(appDir.path, 'notes.db');
  final database = await databaseFactoryIo.openDatabase(dbPath);
  return database;
}

// Store for notes
final notesStoreProvider = Provider<StoreRef<int, Map<String, dynamic>>>((ref) {
  return intMapStoreFactory.store('notes');
});

// Notes Repository
class NotesRepository {
  final Database _database;
  final StoreRef<int, Map<String, dynamic>> _store;

  NotesRepository(this._database, this._store);

  // Create a new note
  Future<String> createNote(Note note) async {
    final id = await _store.add(_database, note.toMap());
    return id.toString();
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    final snapshots = await _store.find(_database);
    return snapshots.map((snapshot) {
      return Note.fromMap(snapshot.value, snapshot.key.toString());
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by newest first
  }

  // Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    final snapshot = await _store.record(int.parse(id)).get(_database);
    if (snapshot == null) return null;
    return Note.fromMap(snapshot, id);
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    if (note.id == null) return;
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _store.record(int.parse(note.id!)).put(_database, updatedNote.toMap());
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _store.record(int.parse(id)).delete(_database);
  }

  // Delete all notes
  Future<void> deleteAllNotes() async {
    await _store.delete(_database);
  }
}

// Notes repository provider
@riverpod
Future<NotesRepository> notesRepository(Ref ref) async {
  final database = await ref.watch(databaseProvider.future);
  final store = ref.watch(notesStoreProvider);
  return NotesRepository(database, store);
}

// Notes list provider - Stream that watches for changes
@riverpod
Stream<List<Note>> notesList(Ref ref) async* {
  final repository = await ref.watch(notesRepositoryProvider.future);

  // Initial load
  yield await repository.getAllNotes();

  // Poll for changes every 500ms
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500));
    yield await repository.getAllNotes();
  }
}