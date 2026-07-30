import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/content_block.dart';
import '../models/journey_entity.dart';
class LedgerDB extends GetxService {
  static const String _photoDirName = 'journey_photos';
  late Database _db;
  Future<LedgerDB> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ledger.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return this;
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journey (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        photos TEXT,
        cover_image_path TEXT,
        trip_start_date TEXT,
        trip_end_date TEXT,
        tags TEXT,
        trip_spend REAL,
        photo_captions TEXT,
        body_blocks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE journey ADD COLUMN tags TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE journey ADD COLUMN trip_spend REAL');
      await db.execute('ALTER TABLE journey ADD COLUMN photo_captions TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE journey ADD COLUMN body_blocks TEXT');
    }
  }
  Database get db => _db;
  Future<String> getPhotosDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(join(docs.path, _photoDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }
  Future<String> resolvePhotoPath(String relativePath) async {
    final docs = await getApplicationDocumentsDirectory();
    return join(docs.path, relativePath);
  }
  Future<String> newPhotoAbsolutePath() async {
    final dirPath = await getPhotosDirectory();
    final rand = Random().nextInt(9999).toString().padLeft(4, '0');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$rand.jpg';
    return join(dirPath, fileName);
  }
  Future<String> copyPhotoToLocal(String sourceAbsolutePath) async {
    final dest = await newPhotoAbsolutePath();
    await File(sourceAbsolutePath).copy(dest);
    return dest;
  }
  String toRelativePhotoPath(String absolutePath) {
    final parts = absolutePath.split('/');
    final photosDirIndex = parts.lastIndexOf(_photoDirName);
    if (photosDirIndex >= 0 && photosDirIndex < parts.length - 1) {
      return '$_photoDirName/${parts[photosDirIndex + 1]}';
    }
    return absolutePath;
  }
  Future<String?> duplicatePhotoRelative(String relativePath) async {
    if (relativePath.isEmpty) return null;
    try {
      final abs = await resolvePhotoPath(relativePath);
      if (!await File(abs).exists()) return null;
      final destAbs = await copyPhotoToLocal(abs);
      return toRelativePhotoPath(destAbs);
    } catch (_) {
      return null;
    }
  }
  Future<List<JourneyEntity>> getJourneys() async {
    final maps = await _db.query(
      'journey',
      orderBy: 'created_at DESC, id DESC',
    );
    return maps.map(JourneyEntity.fromMap).toList();
  }
  Future<JourneyEntity?> getJourney(int id) async {
    final maps = await _db.query(
      'journey',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JourneyEntity.fromMap(maps.first);
  }
  Future<int> insertJourney(JourneyEntity journey) async {
    try {
      return await _db.insert('journey', journey.toMap());
    } catch (e) {
      rethrow;
    }
  }
  Future<int> updateJourney(JourneyEntity journey) async {
    try {
      if (journey.id == null) return 0;
      return await _db.update(
        'journey',
        journey.toMap(),
        where: 'id = ?',
        whereArgs: [journey.id],
      );
    } catch (e) {
      rethrow;
    }
  }
  Future<int> deleteJourney(int id) async {
    try {
      final journey = await getJourney(id);
      if (journey != null) {
        await _deleteJourneyPhotos(journey);
      }
      return await _db.delete(
        'journey',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }
  Future<void> clearJourneys() async {
    try {
      await _db.delete('journey');
      await _clearPhotosDirectory();
    } catch (e) {
      rethrow;
    }
  }
  Future<void> _deleteJourneyPhotos(JourneyEntity journey) async {
    final paths = <String>{
      ...journey.photoList,
      ...ContentBlock.imagePaths(journey.resolvedBlocks),
      if (journey.coverImagePath != null &&
          journey.coverImagePath!.isNotEmpty)
        journey.coverImagePath!,
    };
    for (final relative in paths) {
      try {
        final fullPath = await resolvePhotoPath(relative);
        final file = File(fullPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
  Future<void> _clearPhotosDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(join(docs.path, _photoDirName));
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
  }
}
