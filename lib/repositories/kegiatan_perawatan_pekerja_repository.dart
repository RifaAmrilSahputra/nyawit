import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kegiatan_perawatan_pekerja.dart';
import 'package:sqflite/sqflite.dart';

class KegiatanPerawatanPekerjaRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<List<KegiatanPerawatanPekerja>> getByKegiatanId(int kegiatanId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'kegiatan_perawatan_pekerja',
      where: 'kegiatan_perawatan_id = ?',
      whereArgs: [kegiatanId],
    );
    return rows.map(KegiatanPerawatanPekerja.fromMap).toList();
  }

  Future<void> replaceRelations(
    int kegiatanId,
    List<KegiatanPerawatanPekerja> pekerjas,
  ) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'kegiatan_perawatan_pekerja',
        where: 'kegiatan_perawatan_id = ?',
        whereArgs: [kegiatanId],
      );
      for (final p in pekerjas) {
        final map = p.toMap()..['kegiatan_perawatan_id'] = kegiatanId;
        await txn.insert(
          'kegiatan_perawatan_pekerja',
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}
