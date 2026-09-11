import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/produk.dart';

class ProdukRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(Produk item) async {
    final db = await _helper.database;
    return await db.insert('produk', item.toMap());
  }

  Future<List<Produk>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('produk', orderBy: 'nama ASC');
    return rows.map(Produk.fromMap).toList();
  }

  Future<Produk?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'produk',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Produk.fromMap(rows.first);
  }

  Future<int> update(Produk item) async {
    final db = await _helper.database;
    return db.update(
      'produk',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }
}
