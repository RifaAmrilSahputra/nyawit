import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/tarif.dart';

class TarifRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;
  Future<List<Tarif>> getAll() async {
    final db = await _helper.database;
    return (await db.query('tarif')).map(Tarif.fromMap).toList();
  }

  Future<Tarif?> getFor(TarifJenis jenis, {int? kebunId}) async {
    final db = await _helper.database;
    final rows = await db.query(
      'tarif',
      where: kebunId == null
          ? 'jenis = ? AND kebun_id IS NULL'
          : 'jenis = ? AND kebun_id = ?',
      whereArgs: kebunId == null ? [jenis.name] : [jenis.name, kebunId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : Tarif.fromMap(rows.first);
  }

  Future<double> nilaiUntuk(TarifJenis jenis, {int? kebunId}) async =>
      (await getFor(jenis, kebunId: kebunId))?.nilaiPerKg ?? 0;
  Future<void> save(Tarif item) async {
    if (item.nilaiPerKg < 0) throw ArgumentError('Tarif tidak boleh negatif');
    final db = await _helper.database;
    final existing = await getFor(item.jenis, kebunId: item.kebunId);
    if (existing == null) {
      await db.insert('tarif', item.toMap());
    } else {
      await db.update(
        'tarif',
        item.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
