import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../constants/app_constants.dart';

/// Helper tunggal untuk mengelola database SQLite lokal aplikasi.
///
/// Pola yang dipakai:
///  1. [database] sebagai getter yang membuka database hanya satu kali.
///  2. [_initDb] untuk membuat database beserta tabelnya.
///  3. Method CRUD di bawahnya untuk dipakai layer presentation.
class DatabaseHelper {
  DatabaseHelper._();

  // ------------------------------------------------------------------
  // Instance & database
  // ------------------------------------------------------------------
  static Database? _database;

  /// Database yang sudah terbuka. Dibuka otomatis saat pertama diakses.
  static Future<Database> get database async {
    // Hindari membuka database dua kali.
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  /// Membuka (dan membuat bila belum ada) database aplikasi.
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableUser} (
            ${AppConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${AppConstants.columnName} TEXT NOT NULL,
            ${AppConstants.columnEmail} TEXT NOT NULL UNIQUE,
            ${AppConstants.columnPassword} TEXT NOT NULL,
            ${AppConstants.columnCreatedAt} TEXT NOT NULL,
            ${AppConstants.columnUpdatedAt} TEXT
          )
        ''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_user_email '
          'ON ${AppConstants.tableUser}(${AppConstants.columnEmail})',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Belum ada perubahan skema pada versi sebelumnya.
      },
    );
  }
  // ------------------------------------------------------------------
  // Create
  // ------------------------------------------------------------------

  /// Menambahkan pengguna baru.
  /// Mengembalikan `id` baris yang baru dibuat.
  static Future<int> insertUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    return db.insert(AppConstants.tableUser, {
      AppConstants.columnName: name.trim(),
      AppConstants.columnEmail: email.trim().toLowerCase(),
      AppConstants.columnPassword: password,
      AppConstants.columnCreatedAt: DateTime.now().toIso8601String(),
      AppConstants.columnUpdatedAt: null,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // ------------------------------------------------------------------
  // Read
  // ------------------------------------------------------------------

  /// Mengambil semua pengguna, terbaru lebih dulu.
  static Future<List<Map<String, Object?>>> getAllUsers() async {
    final db = await database;
    return db.query(
      AppConstants.tableUser,
      orderBy: '${AppConstants.columnId} DESC',
    );
  }

  /// Mencari satu pengguna berdasarkan email. `null` bila tidak ditemukan.
  static Future<Map<String, Object?>?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableUser,
      where: '${AppConstants.columnEmail} = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Mencari satu pengguna berdasarkan id.
  static Future<Map<String, Object?>?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableUser,
      where: '${AppConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }
  // ------------------------------------------------------------------
  // Validasi login
  // ------------------------------------------------------------------

  /// `true` bila email sudah dipakai pengguna lain.
  static Future<bool> isEmailRegistered(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Memvalidasi kredensial.
  /// Mengembalikan data user bila benar, `null` bila email/password salah.
  static Future<Map<String, Object?>?> login({
    required String email,
    required String password,
  }) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;
    if (user[AppConstants.columnPassword] != password) return null;
    return user;
  }

  // ------------------------------------------------------------------
  // Update & Delete
  // ------------------------------------------------------------------

  /// Memperbarui profil pengguna. Mengembalikan jumlah baris yang berubah.
  static Future<int> updateUser({
    required int id,
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    return db.update(
      AppConstants.tableUser,
      {
        AppConstants.columnName: name.trim(),
        AppConstants.columnEmail: email.trim().toLowerCase(),
        AppConstants.columnPassword: password,
        AppConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${AppConstants.columnId} = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Menghapus pengguna berdasarkan id.
  static Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableUser,
      where: '${AppConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // ------------------------------------------------------------------
  // Utilitas
  // ------------------------------------------------------------------

  /// Jumlah pengguna yang terdaftar.
  static Future<int> countUsers() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppConstants.tableUser}',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Menghapus seluruh isi tabel pengguna.
  static Future<int> deleteAllUsers() async {
    final db = await database;
    return db.delete(AppConstants.tableUser);
  }

  /// Menutup koneksi database (berguna saat logout atau akhir siklus app).
  static Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }
}
