import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_page.dart';
import '../features/notes/view_notes_page.dart';
import '../features/notes/create_note_page.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/view-notes',
        name: 'viewNotes',
        builder: (context, state) => const ViewNotesPage(),
      ),
      GoRoute(
        path: '/create-note',
        name: 'createNote',
        builder: (context, state) {
          final noteId = state.uri.queryParameters['id']; // parse query param 'id'
          return CreateNotePage(noteId: noteId);
        },
      ),
    ],
  );
});
