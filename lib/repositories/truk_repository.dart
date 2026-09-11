import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/truk.dart';

class TrukRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Truk truk) async {
    final db = await _databaseHelper.database;
    return db.insert('truk', truk.toMap());
  }

  Future<List<Truk>> getAll() async {
    final db = await _databaseHelper.database;
    final result = await db.query('truk', orderBy: 'jenis ASC, nama_supir ASC');
    return result.map(Truk.fromMap).toList();
  }

  Future<int> update(Truk truk) async {
    final db = await _databaseHelper.database;
    return db.update(
      'truk',
      truk.toMap(),
      where: 'id = ?',
      whereArgs: [truk.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('truk', where: 'id = ?', whereArgs: [id]);
  }
}
