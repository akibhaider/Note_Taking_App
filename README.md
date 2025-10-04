Project structure:

lib/
├── main.dart
├── app.dart
├── core/
│   ├── database_provider.dart
│   ├── database_provider.g.dart (generated)
│   ├── router.dart
│   └── theme.dart (optional)
└── features/
├── theme/
│   ├── theme_provider.dart
│   └── theme_provider.g.dart (generated)
├── font/
│   ├── font_provider.dart
│   └── font_provider.g.dart (generated)
├── home/
│   └── home_page.dart
└── notes/
├── view_notes_page.dart
└── create_note_page.dart