import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/models/panen_pekerja.dart';
import 'package:nyawit/models/pengangkutan.dart';
import 'package:nyawit/models/biaya_panen.dart';
import 'package:nyawit/models/tarif.dart';
import 'package:sqflite/sqflite.dart';

class PanenRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Panen panen) async {
    final db = await _databaseHelper.database;
    return await db.insert('panen', panen.toMap());
  }

  Future<int> insertWithRelations(
    Panen panen,
    List<PanenPekerja> pekerja,
    List<Pengangkutan> pengangkutan, {
    List<BiayaPanen> biaya = const [],
    Map<TarifJenis, double> pembayaran = const {},
  }) async {
    final db = await _databaseHelper.database;
    return await db.transaction<int>((txn) async {
      final panenId = await txn.insert('panen', panen.toMap());

      for (final p in pekerja) {
        final map = p.toMap();
        map['panen_id'] = panenId;
        await txn.insert(
          'panen_pekerja',
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      for (final k in pengangkutan) {
        final map = k.toMap();
        map['panen_id'] = panenId;
        await txn.insert('pengangkutan', map);
      }
      for (final item in biaya) {
        final biayaId = await txn.insert(
          'biaya_panen',
          item.toMap()..['panen_id'] = panenId,
        );
        final dibayar = pembayaran[item.jenis] ?? 0;
        if (dibayar > 0) {
          await txn.insert('pembayaran_biaya_panen', {
            'biaya_panen_id': biayaId,
            'jumlah': dibayar,
            'tanggal': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      return panenId;
    });
  }

  Future<List<Panen>> getAll() async {
    final db = await _databaseHelper.database;
    final result = await db.query('panen', orderBy: 'tanggal DESC');
    return result.map((m) => Panen.fromMap(m)).toList();
  }

  Future<Panen?> getById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'panen',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Panen.fromMap(result.first);
  }

  Future<int> update(Panen panen) async {
    final db = await _databaseHelper.database;
    return db.update(
      'panen',
      panen.toMap(),
      where: 'id = ?',
      whereArgs: [panen.id],
    );
  }

  /// Replaces only the relations owned by this harvest in the same transaction.
  /// Master kebun, pekerja, and truk records are never changed here.
  Future<void> updateWithRelations(
    Panen panen,
    List<PanenPekerja> pekerja,
    List<Pengangkutan> pengangkutan, {
    List<BiayaPanen>? biaya,
    Map<TarifJenis, double> pembayaran = const {},
  }) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'panen',
        panen.toMap(),
        where: 'id = ?',
        whereArgs: [panen.id],
      );
      await txn.delete(
        'panen_pekerja',
        where: 'panen_id = ?',
        whereArgs: [panen.id],
      );
      await txn.delete(
        'pengangkutan',
        where: 'panen_id = ?',
        whereArgs: [panen.id],
      );

      for (final relation in pekerja) {
        final map = relation.toMap()..['panen_id'] = panen.id;
        await txn.insert('panen_pekerja', map);
      }
      for (final item in pengangkutan) {
        final map = item.toMap()..['panen_id'] = panen.id;
        await txn.insert('pengangkutan', map);
      }
      if (biaya != null) {
        await txn.delete(
          'biaya_panen',
          where: 'panen_id = ?',
          whereArgs: [panen.id],
        );
        for (final item in biaya) {
          final biayaId = await txn.insert(
            'biaya_panen',
            item.toMap()..['panen_id'] = panen.id,
          );
          final dibayar = pembayaran[item.jenis] ?? 0;
          if (dibayar > 0) {
            final now = DateTime.now().toIso8601String();
            await txn.insert('pembayaran_biaya_panen', {
              'biaya_panen_id': biayaId,
              'jumlah': dibayar,
              'tanggal': now,
              'created_at': now,
            });
          }
        }
      }
    });
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return db.transaction((txn) async {
      // Explicit deletes keep the behavior correct even on older databases
      // where foreign-key cascade was not enabled when they were opened.
      await txn.delete('panen_pekerja', where: 'panen_id = ?', whereArgs: [id]);
      await txn.delete('pengangkutan', where: 'panen_id = ?', whereArgs: [id]);
      await txn.delete('biaya_panen', where: 'panen_id = ?', whereArgs: [id]);
      return txn.delete('panen', where: 'id = ?', whereArgs: [id]);
    });
  }
}
