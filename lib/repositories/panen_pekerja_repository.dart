import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/panen_pekerja.dart';
import 'package:sqflite/sqflite.dart';

class PanenPekerjaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<PanenPekerja>> getByPanenId(int panenId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'panen_pekerja',
      where: 'panen_id = ?',
      whereArgs: [panenId],
    );
    return result.map(PanenPekerja.fromMap).toList();
  }

  Future<void> save(PanenPekerja relation) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'panen_pekerja',
      relation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int panenId, int pekerjaId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'panen_pekerja',
      where: 'panen_id = ? AND pekerja_id = ?',
      whereArgs: [panenId, pekerjaId],
    );
  }
}
