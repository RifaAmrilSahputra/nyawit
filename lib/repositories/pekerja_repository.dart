import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/pekerja.dart';

class PekerjaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Pekerja pekerja) async {
    final db = await _databaseHelper.database;
    return db.insert('pekerja', pekerja.toMap());
  }

  Future<List<Pekerja>> getAll() async {
    final db = await _databaseHelper.database;
    final result = await db.query('pekerja', orderBy: 'nama ASC');
    return result.map(Pekerja.fromMap).toList();
  }

  Future<int> update(Pekerja pekerja) async {
    final db = await _databaseHelper.database;
    return db.update(
      'pekerja',
      pekerja.toMap(),
      where: 'id = ?',
      whereArgs: [pekerja.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('pekerja', where: 'id = ?', whereArgs: [id]);
  }
}
