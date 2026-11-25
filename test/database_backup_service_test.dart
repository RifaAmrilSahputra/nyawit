import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:nyawit/core/database/database_backup_service.dart';
import 'package:nyawit/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  var hasSqlite = true;
  try {
    DynamicLibrary.open('libsqlite3.so');
  } catch (_) {
    hasSqlite = false;
  }

  if (hasSqlite) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  test(
    'backup restore replaces the complete database in a single transaction',
    () async {
      final db = await DatabaseHelper.instance.database;
      final service = DatabaseBackupService(databaseProvider: () async => db);
      const key = 'backup_restore_service_test';

      await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
      await db.insert('app_settings', {
        'key': key,
        'value': 'before',
      });

      final backup = await service.createBackup();
      await db.update(
        'app_settings',
        {'value': 'after'},
        where: 'key = ?',
        whereArgs: [key],
      );

      final preview = await service.inspectBackup(backup);
      expect(preview.totalRows, greaterThan(0));
      expect(preview.rowsByTable['app_settings'], greaterThan(0));

      await service.restoreBackup(backup);
      final restored = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
      );

      expect(restored.single['value'], 'before');
      await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
    },
    skip: !hasSqlite
        ? 'Skipped in CI: enable by installing native libsqlite3'
        : false,
  );
}
