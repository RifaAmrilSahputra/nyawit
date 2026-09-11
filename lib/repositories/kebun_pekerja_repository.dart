import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kebun_pekerja.dart';
import 'package:sqflite/sqflite.dart';

class KebunPekerjaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<KebunPekerja>> getByKebunId(int kebunId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'kebun_pekerja',
      where: 'kebun_id = ?',
      whereArgs: [kebunId],
      orderBy: 'is_default DESC, id ASC',
    );
    return result.map(KebunPekerja.fromMap).toList();
  }

  Future<void> save(KebunPekerja relation) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      if (relation.isDefault) {
        await txn.update(
          'kebun_pekerja',
          {'is_default': 0},
          where: 'kebun_id = ?',
          whereArgs: [relation.kebunId],
        );
      }

      await txn.insert(
        'kebun_pekerja',
        relation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> delete(int kebunId, int pekerjaId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'kebun_pekerja',
      where: 'kebun_id = ? AND pekerja_id = ?',
      whereArgs: [kebunId, pekerjaId],
    );
  }
}
