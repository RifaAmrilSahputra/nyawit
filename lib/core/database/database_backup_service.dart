import 'dart:convert';

import 'package:nyawit/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseBackupService {
  DatabaseBackupService({Future<Database> Function()? databaseProvider})
    : _databaseProvider =
          databaseProvider ?? (() => DatabaseHelper.instance.database);

  static const _formatName = 'nyawit-database-backup';
  static const _formatVersion = 1;

  static const _tables = [
    'kebun',
    'pekerja',
    'truk',
    'produk',
    'lokasi_timbang',
    'app_settings',
    'kebun_pekerja',
    'kebun_truk',
    'tarif',
    'tarif_perawatan',
    'panen',
    'kegiatan_perawatan',
    'panen_pekerja',
    'pengangkutan',
    'biaya_panen',
    'kegiatan_perawatan_pekerja',
    'pembayaran_perawatan',
    'status_kegiatan_perawatan',
    'pembayaran_biaya_panen',
  ];

  final Future<Database> Function() _databaseProvider;

  Future<String> createBackup() async {
    final db = await _databaseProvider();
    final tables = <String, List<Map<String, Object?>>>{};

    for (final table in _tables) {
      tables[table] = await db.query(table);
    }

    return const JsonEncoder.withIndent('  ').convert({
      'format': _formatName,
      'formatVersion': _formatVersion,
      'schemaVersion': await db.getVersion(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
    });
  }

  Future<DatabaseBackupSummary> inspectBackup(String content) async {
    final db = await _databaseProvider();
    final payload = await _decodeAndValidate(content, await db.getVersion());
    final tables = payload['tables']! as Map<String, Object?>;
    final rowsByTable = <String, int>{};

    for (final table in _tables) {
      rowsByTable[table] = (tables[table]! as List).length;
    }

    return DatabaseBackupSummary(
      createdAt: DateTime.parse(payload['createdAt']! as String),
      rowsByTable: rowsByTable,
    );
  }

  Future<DatabaseBackupSummary> restoreBackup(String content) async {
    final db = await _databaseProvider();
    final payload = await _decodeAndValidate(content, await db.getVersion());
    final tables = payload['tables']! as Map<String, Object?>;
    final rowsByTable = <String, int>{};

    for (final table in _tables) {
      rowsByTable[table] = (tables[table]! as List).length;
    }

    await db.transaction((transaction) async {
      for (final table in _tables.reversed) {
        await transaction.delete(table);
      }

      for (final table in _tables) {
        final rows = tables[table]! as List<Object?>;
        for (final row in rows) {
          await transaction.insert(table, row! as Map<String, Object?>);
        }
      }

      final violations = await transaction.rawQuery('PRAGMA foreign_key_check');
      if (violations.isNotEmpty) {
        throw const FormatException(
          'Backup berisi relasi data yang tidak valid.',
        );
      }
    });

    return DatabaseBackupSummary(
      createdAt: DateTime.parse(payload['createdAt']! as String),
      rowsByTable: rowsByTable,
    );
  }

  Future<Map<String, Object?>> _decodeAndValidate(
    String content,
    int currentSchemaVersion,
  ) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format file backup tidak valid.');
    }

    if (decoded['format'] != _formatName ||
        decoded['formatVersion'] != _formatVersion) {
      throw const FormatException('File bukan backup Nyawit yang didukung.');
    }

    if (decoded['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException(
        'Versi struktur backup tidak cocok dengan versi aplikasi ini.',
      );
    }

    final createdAtValue = decoded['createdAt'];
    if (createdAtValue is! String ||
        DateTime.tryParse(createdAtValue) == null) {
      throw const FormatException('Tanggal backup tidak valid.');
    }

    final rawTables = decoded['tables'];
    if (rawTables is! Map<String, dynamic> ||
        rawTables.keys.toSet().difference(_tables.toSet()).isNotEmpty ||
        _tables.toSet().difference(rawTables.keys.toSet()).isNotEmpty) {
      throw const FormatException(
        'Daftar tabel pada file backup tidak lengkap atau tidak dikenal.',
      );
    }

    final tables = <String, Object?>{};
    for (final table in _tables) {
      final rawRows = rawTables[table];
      if (rawRows is! List) {
        throw FormatException('Data tabel "$table" tidak valid.');
      }

      final columns = await _columnNames(table);
      final rows = <Map<String, Object?>>[];
      for (final rawRow in rawRows) {
        if (rawRow is! Map<String, dynamic> ||
            rawRow.keys.any((key) => !columns.contains(key))) {
          throw FormatException('Baris data tabel "$table" tidak valid.');
        }
        rows.add(Map<String, Object?>.from(rawRow));
      }
      tables[table] = rows;
    }

    return {'createdAt': createdAtValue, 'tables': tables};
  }

  Future<Set<String>> _columnNames(String table) async {
    final db = await _databaseProvider();
    final rows = await db.rawQuery('PRAGMA table_info("$table")');
    return rows.map((row) => row['name']! as String).toSet();
  }
}

class DatabaseBackupSummary {
  const DatabaseBackupSummary({
    required this.createdAt,
    required this.rowsByTable,
  });

  final DateTime createdAt;
  final Map<String, int> rowsByTable;

  int get totalRows =>
      rowsByTable.values.fold(0, (total, count) => total + count);
}
