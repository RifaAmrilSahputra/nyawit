import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/kegiatan_perawatan_pekerja.dart';
import 'package:sqflite/sqflite.dart';

class KegiatanPerawatanRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(KegiatanPerawatan item) async {
    final db = await _helper.database;
    return await db.insert('kegiatan_perawatan', item.toMap());
  }

  Future<int> insertWithRelations(
    KegiatanPerawatan item,
    List<KegiatanPerawatanPekerja> pekerjas,
  ) async {
    final db = await _helper.database;
    return await db.transaction<int>((txn) async {
      final id = await txn.insert('kegiatan_perawatan', item.toMap());
      for (final p in pekerjas) {
        final map = p.toMap()..['kegiatan_perawatan_id'] = id;
        await txn.insert(
          'kegiatan_perawatan_pekerja',
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      return id;
    });
  }

  Future<List<KegiatanPerawatan>> getAll({int? kebunId}) async {
    final db = await _helper.database;
    final result = kebunId == null
        ? await db.query('kegiatan_perawatan', orderBy: 'tanggal_mulai DESC')
        : await db.query(
            'kegiatan_perawatan',
            where: 'kebun_id = ?',
            whereArgs: [kebunId],
            orderBy: 'tanggal_mulai DESC',
          );
    return result.map(KegiatanPerawatan.fromMap).toList();
  }

  Future<KegiatanPerawatan?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'kegiatan_perawatan',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return KegiatanPerawatan.fromMap(rows.first);
  }

  Future<int> update(KegiatanPerawatan item) async {
    final db = await _helper.database;
    return await db.update(
      'kegiatan_perawatan',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> updateWithRelations(
    KegiatanPerawatan item,
    List<KegiatanPerawatanPekerja> pekerjas,
  ) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      await txn.update(
        'kegiatan_perawatan',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      await txn.delete(
        'kegiatan_perawatan_pekerja',
        where: 'kegiatan_perawatan_id = ?',
        whereArgs: [item.id],
      );
      for (final p in pekerjas) {
        final map = p.toMap()..['kegiatan_perawatan_id'] = item.id;
        await txn.insert(
          'kegiatan_perawatan_pekerja',
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return await db.transaction((txn) async {
      await txn.delete(
        'kegiatan_perawatan_pekerja',
        where: 'kegiatan_perawatan_id = ?',
        whereArgs: [id],
      );
      return await txn.delete(
        'kegiatan_perawatan',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
