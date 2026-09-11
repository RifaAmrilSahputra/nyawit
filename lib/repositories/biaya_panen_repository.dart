import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/biaya_panen.dart';
import 'package:sqflite/sqflite.dart';

class BiayaPanenRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;
  Future<List<BiayaPanen>> getByPanenId(int panenId) async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT b.*, COALESCE(SUM(p.jumlah), 0) AS jumlah_dibayarkan FROM biaya_panen b LEFT JOIN pembayaran_biaya_panen p ON p.biaya_panen_id = b.id WHERE b.panen_id = ? GROUP BY b.id ORDER BY b.id',
      [panenId],
    );
    return rows.map(BiayaPanen.fromMap).toList();
  }

  Future<void> replacePayments(
    DatabaseExecutor db,
    int biayaId,
    double jumlah,
    DateTime now,
  ) async {
    if (jumlah < 0) throw ArgumentError('Pembayaran tidak boleh negatif');
    await db.delete(
      'pembayaran_biaya_panen',
      where: 'biaya_panen_id = ?',
      whereArgs: [biayaId],
    );
    if (jumlah > 0) {
      await db.insert('pembayaran_biaya_panen', {
        'biaya_panen_id': biayaId,
        'jumlah': jumlah,
        'tanggal': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      });
    }
  }
}
