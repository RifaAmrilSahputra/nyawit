import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kebun_truk.dart';
import 'package:sqflite/sqflite.dart';

class KebunTrukRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<KebunTruk>> getByKebunId(int kebunId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'kebun_truk',
      where: 'kebun_id = ?',
      whereArgs: [kebunId],
      orderBy: 'is_default DESC, id ASC',
    );
    return result.map(KebunTruk.fromMap).toList();
  }

  Future<void> save(KebunTruk relation) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      if (relation.isDefault) {
        await txn.update(
          'kebun_truk',
          {'is_default': 0},
          where: 'kebun_id = ?',
          whereArgs: [relation.kebunId],
        );
      }

      await txn.insert(
        'kebun_truk',
        relation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> delete(int kebunId, int trukId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'kebun_truk',
      where: 'kebun_id = ? AND truk_id = ?',
      whereArgs: [kebunId, trukId],
    );
  }
}
