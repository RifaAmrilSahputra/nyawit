import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kebun.dart';

class KebunRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Kebun kebun) async {
    final db = await _databaseHelper.database;

    return await db.insert('kebun', kebun.toMap());
  }

  Future<List<Kebun>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query('kebun', orderBy: 'nama ASC');

    return result.map((map) => Kebun.fromMap(map)).toList();
  }

  Future<Kebun?> getById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'kebun',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Kebun.fromMap(result.first);
  }

  Future<int> update(Kebun kebun) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'kebun',
      kebun.toMap(),
      where: 'id = ?',
      whereArgs: [kebun.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete('kebun', where: 'id = ?', whereArgs: [id]);
  }
}
