import 'dart:ffi';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/kebun_truk.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/models/panen_pekerja.dart';
import 'package:nyawit/models/pengangkutan.dart';
import 'package:nyawit/models/produk.dart';

import 'package:nyawit/repositories/panen_repository.dart';
import 'package:nyawit/repositories/panen_pekerja_repository.dart';
import 'package:nyawit/repositories/pengangkutan_repository.dart';
import 'package:nyawit/repositories/lokasi_timbang_repository.dart';
import 'package:nyawit/repositories/kebun_truk_repository.dart';
import 'package:nyawit/repositories/produk_repository.dart';

void main() {
  // detect native sqlite3 availability before initializing FFI
  var hasSqlite = true;
  try {
    DynamicLibrary.open('libsqlite3.so');
  } catch (_) {
    try {
      DynamicLibrary.open('libsqlite3.so.0');
    } catch (_) {
      hasSqlite = false;
    }
  }

  if (hasSqlite) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  group('DB repositories integration', () {
    final dbHelper = DatabaseHelper.instance;
    final panenRepo = PanenRepository();
    final panenPekerjaRepo = PanenPekerjaRepository();
    final pengangkutanRepo = PengangkutanRepository();
    final lokasiRepo = LokasiTimbangRepository();
    final kebunTrukRepo = KebunTrukRepository();

    test('Kebun.fromMap tolerates missing or malformed date values', () {
      final kebun = Kebun.fromMap({
        'id': 1,
        'nama': 'Kebun Demo',
        'lokasi': 'Lampung',
        'luas': 12.5,
        'jumlah_pohon': 350,
        'keterangan': 'Data legacy',
        'created_at': '',
        'updated_at': '2024-01-01 08:30:00',
      });

      expect(kebun.nama, 'Kebun Demo');
      expect(kebun.createdAt, isA<DateTime>());
      expect(kebun.updatedAt, isA<DateTime>());
    });

    test(
      'ProdukRepository supports create, update, and delete for master data',
      () async {
        final repo = ProdukRepository();
        final now = DateTime.now();

        final created = await repo.insert(
          Produk(
            nama: 'Pupuk NPK',
            jenis: 'pupuk',
            satuanDefault: 'sak',
            aktif: true,
            keterangan: 'Produk awal',
            createdAt: now,
            updatedAt: now,
          ),
        );

        final items = await repo.getAll();
        expect(items.any((item) => item.id == created), isTrue);

        final updated = await repo.update(
          Produk(
            id: created,
            nama: 'Pupuk NPK Premium',
            jenis: 'pupuk',
            satuanDefault: 'sak',
            aktif: true,
            keterangan: 'Produk diperbarui',
            createdAt: now,
            updatedAt: DateTime.now(),
          ),
        );
        expect(updated, equals(1));

        final detail = await repo.getById(created);
        expect(detail?.nama, 'Pupuk NPK Premium');

        final deleted = await repo.delete(created);
        expect(deleted, equals(1));
      },
    );

    test(
      'migrations and relations work with transactions and cascade',
      () async {
        final db = await dbHelper.database;

        // insert master records
        final now = DateTime.now();
        final kebunId = await db.insert(
          'kebun',
          Kebun(nama: 'K1', createdAt: now, updatedAt: now).toMap(),
        );
        final pekerjaId1 = await db.insert(
          'pekerja',
          Pekerja(
            nama: 'P1',
            status: 'aktif',
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
        final pekerjaId2 = await db.insert(
          'pekerja',
          Pekerja(
            nama: 'P2',
            status: 'aktif',
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
        final trukId = await db.insert(
          'truk',
          Truk(
            jenis: 'A',
            namaSupir: 'Supir',
            status: 'aktif',
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );

        final lokasiId = await lokasiRepo.insert(
          LokasiTimbang(
            nama: 'LT1',
            jenis: WeighbridgeType.ram,
            aktif: true,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // insert kebun_truk relation
        await kebunTrukRepo.save(
          KebunTruk(
            kebunId: kebunId,
            trukId: trukId,
            isDefault: true,
            aktif: true,
          ),
        );

        // create panen with relations
        final panen = Panen(
          kebunId: kebunId,
          tanggal: now,
          beratBersih: 100.0,
          hargaSawit: 2000.0,
          sortir: 1.0,
          shippingMethod: ShippingMethod.antar,
          lokasiTimbangId: lokasiId,
          createdAt: now,
          updatedAt: now,
        );

        final pekerjaRelations = [
          PanenPekerja(panenId: 0, pekerjaId: pekerjaId1),
          PanenPekerja(panenId: 0, pekerjaId: pekerjaId2),
        ];

        final pengangkutans = [
          Pengangkutan(panenId: 0, trukId: trukId, beratBersih: 60.0),
          Pengangkutan(panenId: 0, trukId: trukId, beratBersih: 40.0),
        ];

        final panenId = await panenRepo.insertWithRelations(
          panen,
          pekerjaRelations,
          pengangkutans,
        );

        final pRows = await db.query('panen');
        expect(pRows.length, greaterThanOrEqualTo(1));

        final pp = await panenPekerjaRepo.getByPanenId(panenId);
        expect(pp.length, equals(2));

        final pk = await pengangkutanRepo.getByPanenId(panenId);
        expect(pk.length, equals(2));

        // test cascade: delete panen -> pengangkutan and panen_pekerja removed
        final deleted = await panenRepo.delete(panenId);
        expect(deleted, equals(1));

        final ppAfter = await panenPekerjaRepo.getByPanenId(panenId);
        expect(ppAfter.isEmpty, isTrue);

        final pkAfter = await pengangkutanRepo.getByPanenId(panenId);
        expect(pkAfter.isEmpty, isTrue);
      },
      skip:
          'Skipped in CI: enable by installing native libsqlite3 (apt install libsqlite3-dev)',
    );
  });
}
