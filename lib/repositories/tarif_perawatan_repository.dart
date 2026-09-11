import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/tarif_perawatan.dart';

class TarifPerawatanRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<List<TarifPerawatan>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      'tarif_perawatan',
      orderBy: 'kebun_id ASC, jenis ASC',
    );
    return rows.map(TarifPerawatan.fromMap).toList();
  }

  Future<TarifPerawatan?> getFor(
    JenisPerawatan jenis, {
    int? kebunId,
    int? produkId,
  }) async {
    final db = await _helper.database;
    // Prefer tarif matching produk_id when provided (for pupuk), otherwise
    // match by kebun_id (or NULL kebun_id for global defaults).
    if (produkId != null) {
      final rows = await db.query(
        'tarif_perawatan',
        where: 'jenis = ? AND produk_id = ? AND kebun_id = ?',
        whereArgs: [jenis.value, produkId, kebunId ?? -1],
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      if (rows.isNotEmpty) return TarifPerawatan.fromMap(rows.first);
      // fallback: try without produk_id but same kebun
      final rows2 = await db.query(
        'tarif_perawatan',
        where: kebunId == null
            ? 'jenis = ? AND kebun_id IS NULL'
            : 'jenis = ? AND kebun_id = ?',
        whereArgs: kebunId == null ? [jenis.value] : [jenis.value, kebunId],
        orderBy: 'updated_at DESC',
        limit: 1,
      );
      return rows2.isEmpty ? null : TarifPerawatan.fromMap(rows2.first);
    }

    final where = kebunId == null
        ? 'jenis = ? AND kebun_id IS NULL'
        : 'jenis = ? AND kebun_id = ?';
    final whereArgs = kebunId == null ? [jenis.value] : [jenis.value, kebunId];
    final rows = await db.query(
      'tarif_perawatan',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : TarifPerawatan.fromMap(rows.first);
  }

  Future<void> save(TarifPerawatan item) async {
    if (item.tarif < 0) throw ArgumentError('Tarif tidak boleh negatif');
    final db = await _helper.database;
    final existing = await getFor(item.jenis, kebunId: item.kebunId);
    if (existing == null) {
      await db.insert('tarif_perawatan', item.toMap());
    } else {
      await db.update(
        'tarif_perawatan',
        item.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
