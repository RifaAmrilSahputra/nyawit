import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/pengangkutan.dart';

class PengangkutanRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Pengangkutan p) async {
    final db = await _databaseHelper.database;
    return db.insert('pengangkutan', p.toMap());
  }

  Future<List<Pengangkutan>> getByPanenId(int panenId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'pengangkutan',
      where: 'panen_id = ?',
      whereArgs: [panenId],
    );
    return result.map(Pengangkutan.fromMap).toList();
  }

  Future<int> update(Pengangkutan p) async {
    final db = await _databaseHelper.database;
    return db.update(
      'pengangkutan',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('pengangkutan', where: 'id = ?', whereArgs: [id]);
  }
}
