import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  late Database db;

  Future<bool> doesDatabaseExist() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'butler_chat.sqlite');
    return File(dbPath).exists();
  }

  Future<bool> init(String password) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'butler_chat.sqlite');

    // Open the database (creates it if it doesn't exist)
    db = sqlite3.open(dbPath);

    // Set SQLCipher encryption key
    db.execute("PRAGMA key = '${password.replaceAll("'", "''")}';");

    try {
      // Test if password is correct by trying to read the schema
      db.select('SELECT count(*) FROM sqlite_schema;');
    } catch (e) {
      // Wrong password or corrupted database
      db.close();
      return false;
    }

    // Enable WAL mode for better performance and concurrency
    db.execute('PRAGMA journal_mode = WAL;');
    
    // Optional: Enable foreign keys if you add relational tables later
    db.execute('PRAGMA foreign_keys = ON;');

    // Handle migrations
    _runMigrations();
    
    return true;
  }

  void _runMigrations() {
    // Check the current version of the database file
    final versionResult = db.select('PRAGMA user_version;');
    int currentVersion = versionResult.first.values.first as int;

    if (currentVersion < 1) {
      // Initial schema creation (Version 1)
      db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        );
      ''');
      db.execute('PRAGMA user_version = 1;');
    }
    
    // Future migrations would go here, e.g.:
    // if (currentVersion < 2) { ... }
  }

  void dispose() {
    db.close();
  }

  void insertMessage(String role, String content) {
    final stmt = db.prepare('INSERT INTO messages (role, content, timestamp) VALUES (?, ?, ?)');
    stmt.execute([role, content, DateTime.now().millisecondsSinceEpoch]);
    stmt.close();
  }

  List<Map<String, dynamic>> getMessages() {
    final ResultSet resultSet = db.select('SELECT * FROM messages ORDER BY timestamp ASC');
    return resultSet.map((row) {
      return {
        'id': row['id'],
        'role': row['role'],
        'content': row['content'],
        'timestamp': row['timestamp'],
      };
    }).toList();
  }
}
