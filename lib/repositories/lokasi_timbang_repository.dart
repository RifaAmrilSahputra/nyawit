import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/lokasi_timbang.dart';

class LokasiTimbangRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(LokasiTimbang lokasi) async {
    final db = await _databaseHelper.database;
    return db.insert('lokasi_timbang', lokasi.toMap());
  }

  Future<List<LokasiTimbang>> getAll() async {
    final db = await _databaseHelper.database;
    final result = await db.query('lokasi_timbang', orderBy: 'nama ASC');
    return result.map(LokasiTimbang.fromMap).toList();
  }

  Future<int> update(LokasiTimbang lokasi) async {
    final db = await _databaseHelper.database;
    return db.update(
      'lokasi_timbang',
      lokasi.toMap(),
      where: 'id = ?',
      whereArgs: [lokasi.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('lokasi_timbang', where: 'id = ?', whereArgs: [id]);
  }
}
