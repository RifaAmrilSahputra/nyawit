import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/kegiatan_perawatan_pekerja.dart';
import 'package:nyawit/models/pembayaran_perawatan.dart';
import 'package:nyawit/models/status_kegiatan_perawatan.dart';
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
    final result = await db.rawQuery('''
      SELECT k.*, COALESCE(SUM(p.jumlah), 0) AS total_dibayar
      FROM kegiatan_perawatan k
      LEFT JOIN pembayaran_perawatan p ON p.kegiatan_perawatan_id = k.id
      ${kebunId == null ? '' : 'WHERE k.kebun_id = ?'}
      GROUP BY k.id
      ORDER BY k.tanggal_mulai DESC
    ''', kebunId == null ? null : [kebunId]);
    return result.map(KegiatanPerawatan.fromMap).toList();
  }

  Future<KegiatanPerawatan?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      '''
      SELECT k.*, COALESCE(SUM(p.jumlah), 0) AS total_dibayar
      FROM kegiatan_perawatan k
      LEFT JOIN pembayaran_perawatan p ON p.kegiatan_perawatan_id = k.id
      WHERE k.id = ?
      GROUP BY k.id
      LIMIT 1
    ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return KegiatanPerawatan.fromMap(rows.first);
  }

  Future<List<PembayaranPerawatan>> getPayments(int kegiatanId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'pembayaran_perawatan',
      where: 'kegiatan_perawatan_id = ?',
      whereArgs: [kegiatanId],
      orderBy: 'tanggal DESC, id DESC',
    );
    return rows.map(PembayaranPerawatan.fromMap).toList();
  }

  Future<int> addPayment(PembayaranPerawatan payment) async {
    final db = await _helper.database;
    return db.insert('pembayaran_perawatan', payment.toMap());
  }

  Future<List<StatusKegiatanPerawatan>> getStatusHistory(int kegiatanId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'status_kegiatan_perawatan',
      where: 'kegiatan_perawatan_id = ?',
      whereArgs: [kegiatanId],
      orderBy: 'tanggal ASC, id ASC',
    );
    return rows.map(StatusKegiatanPerawatan.fromMap).toList();
  }

  Future<int> addStatusHistory(StatusKegiatanPerawatan history) async {
    final db = await _helper.database;
    return db.insert('status_kegiatan_perawatan', history.toMap());
  }

  Future<int> updateStatus(
    int id,
    StatusKegiatan status, {
    required DateTime tanggal,
    String? keterangan,
  }) async {
    final db = await _helper.database;
    final now = DateTime.now();
    return db.transaction((txn) async {
      final updated = await txn.update(
        'kegiatan_perawatan',
        {'status_kegiatan': status.value, 'updated_at': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.insert(
        'status_kegiatan_perawatan',
        StatusKegiatanPerawatan(
          kegiatanPerawatanId: id,
          status: status.value,
          tanggal: tanggal,
          keterangan: keterangan,
          createdAt: now,
          updatedAt: now,
        ).toMap(),
      );
      return updated;
    });
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
