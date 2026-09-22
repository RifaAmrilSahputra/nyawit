import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sawit_management.db');

    return await openDatabase(
      path,
      version: 9,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createKebunTable(db);

    await _createMasterTables(db);
    await _createTransactionTables(db);
    await _createPerawatanTables(db);
    await _createSettingsTable(db);
  }

  Future<void> _createKebunTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        lokasi TEXT,
        luas REAL,
        jumlah_pohon INTEGER,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMasterTables(db);
    }

    // Add new tables in version 3 without dropping existing data
    if (oldVersion < 3) {
      await _createTransactionTables(db);
    }

    if (oldVersion < 4) {
      await _migrateKebunSchema(db);
    }
    if (oldVersion < 5) {
      await _createTarifAndBiayaTables(db);
    }
    if (oldVersion < 6) {
      await _createPerawatanTables(db);
    }
    if (oldVersion < 7) {
      await _createPembayaranPerawatanTable(db);
      await _migrateLegacyPerawatanPayments(db);
    }
    if (oldVersion < 8) {
      await _createStatusKegiatanPerawatanTable(db);
      await _migrateInitialPerawatanStatus(db);
    }
    if (oldVersion < 9) {
      await _createSettingsTable(db);
    }
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPerawatanTables(Database db) async {
    // produk
    await db.execute('''
      CREATE TABLE IF NOT EXISTS produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        jenis TEXT NOT NULL,
        satuan_default TEXT NOT NULL,
        aktif INTEGER NOT NULL DEFAULT 1,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // tarif_perawatan
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tarif_perawatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kebun_id INTEGER NOT NULL,
        jenis TEXT NOT NULL,
        produk_id INTEGER,
        tarif REAL NOT NULL CHECK(tarif >= 0),
        satuan TEXT NOT NULL,
        aktif INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE,
        FOREIGN KEY(produk_id) REFERENCES produk(id) ON DELETE SET NULL
      )
    ''');

    // kegiatan_perawatan
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kegiatan_perawatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kebun_id INTEGER NOT NULL,
        jenis TEXT NOT NULL,
        nama_kegiatan TEXT,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT NOT NULL,
        produk_id INTEGER,
        jumlah REAL,
        satuan TEXT,
        tarif_satuan REAL,
        total_biaya REAL NOT NULL CHECK(total_biaya >= 0),
        dibayarkan REAL NOT NULL DEFAULT 0 CHECK(dibayarkan >= 0),
        status_kegiatan TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE,
        FOREIGN KEY(produk_id) REFERENCES produk(id) ON DELETE SET NULL
      )
    ''');

    // kegiatan_perawatan_pekerja
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kegiatan_perawatan_pekerja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kegiatan_perawatan_id INTEGER NOT NULL,
        pekerja_id INTEGER NOT NULL,
        UNIQUE(kegiatan_perawatan_id, pekerja_id),
        FOREIGN KEY(kegiatan_perawatan_id) REFERENCES kegiatan_perawatan(id) ON DELETE CASCADE,
        FOREIGN KEY(pekerja_id) REFERENCES pekerja(id) ON DELETE CASCADE
      )
    ''');

    // Indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_produk_jenis ON produk(jenis)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tarif_perawatan_kebun ON tarif_perawatan(kebun_id, jenis)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_kegiatan_perawatan_kebun ON kegiatan_perawatan(kebun_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_kegiatan_perawatan_produk_id ON kegiatan_perawatan(produk_id)',
    );
    await _createPembayaranPerawatanTable(db);
    await _createStatusKegiatanPerawatanTable(db);
  }

  Future<void> _createPembayaranPerawatanTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pembayaran_perawatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kegiatan_perawatan_id INTEGER NOT NULL,
        tanggal TEXT NOT NULL,
        jumlah REAL NOT NULL CHECK(jumlah >= 0),
        jenis TEXT NOT NULL DEFAULT 'angsuran',
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(kegiatan_perawatan_id) REFERENCES kegiatan_perawatan(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pembayaran_perawatan_kegiatan_id ON pembayaran_perawatan(kegiatan_perawatan_id)',
    );
  }

  Future<void> _createStatusKegiatanPerawatanTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS status_kegiatan_perawatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kegiatan_perawatan_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(kegiatan_perawatan_id) REFERENCES kegiatan_perawatan(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_status_kegiatan_perawatan_id ON status_kegiatan_perawatan(kegiatan_perawatan_id, tanggal)',
    );
  }

  Future<void> _migrateInitialPerawatanStatus(Database db) async {
    final rows = await db.rawQuery('''
      SELECT k.id, k.status_kegiatan, k.created_at
      FROM kegiatan_perawatan k
      WHERE NOT EXISTS (
        SELECT 1 FROM status_kegiatan_perawatan s
        WHERE s.kegiatan_perawatan_id = k.id
      )
    ''');
    for (final row in rows) {
      await db.insert('status_kegiatan_perawatan', {
        'kegiatan_perawatan_id': row['id'],
        'status': row['status_kegiatan'],
        'tanggal': row['created_at'],
        'keterangan': 'Status awal',
        'created_at': row['created_at'],
        'updated_at': row['created_at'],
      });
    }
  }

  Future<void> _migrateLegacyPerawatanPayments(Database db) async {
    final rows = await db.rawQuery('''
      SELECT id, dibayarkan, created_at, updated_at
      FROM kegiatan_perawatan
      WHERE dibayarkan > 0
        AND NOT EXISTS (
          SELECT 1 FROM pembayaran_perawatan
          WHERE kegiatan_perawatan_id = kegiatan_perawatan.id
        )
    ''');
    for (final row in rows) {
      await db.insert('pembayaran_perawatan', {
        'kegiatan_perawatan_id': row['id'],
        'tanggal': row['updated_at'],
        'jumlah': row['dibayarkan'],
        'jenis': 'angsuran',
        'keterangan': 'Migrasi pembayaran lama',
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
      });
    }
  }

  Future<void> _migrateKebunSchema(Database db) async {
    await _createKebunTable(db);

    final columns = await db.rawQuery('PRAGMA table_info(kebun)');
    final existingColumns = columns
        .map((column) => column['name'] as String)
        .toSet();

    const missingColumns = <String, String>{
      'lokasi': 'TEXT',
      'luas': 'REAL',
      'jumlah_pohon': 'INTEGER',
      'keterangan': 'TEXT',
      'created_at': 'TEXT',
      'updated_at': 'TEXT',
    };

    for (final entry in missingColumns.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE kebun ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }

    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      'UPDATE kebun SET created_at = ? WHERE created_at IS NULL OR created_at = \'\'',
      [now],
    );
    await db.rawUpdate(
      'UPDATE kebun SET updated_at = ? WHERE updated_at IS NULL OR updated_at = \'\'',
      [now],
    );
  }

  Future<void> _createMasterTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pekerja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        no_hp TEXT,
        alamat TEXT,
        status TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS truk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT NOT NULL,
        nama_supir TEXT NOT NULL,
        no_hp TEXT,
        status TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebun_pekerja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kebun_id INTEGER NOT NULL,
        pekerja_id INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        aktif INTEGER NOT NULL DEFAULT 1,
        mulai TEXT,
        selesai TEXT,
        keterangan TEXT,
        UNIQUE(kebun_id, pekerja_id),
        FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE,
        FOREIGN KEY(pekerja_id) REFERENCES pekerja(id) ON DELETE CASCADE
      )
    ''');

    // Ensure existing master tables for future relations
    await db.execute('''
        CREATE TABLE IF NOT EXISTS kebun_truk (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kebun_id INTEGER NOT NULL,
          truk_id INTEGER NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0,
          aktif INTEGER NOT NULL DEFAULT 1,
          mulai TEXT,
          selesai TEXT,
          keterangan TEXT,
          UNIQUE(kebun_id, truk_id),
          FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE,
          FOREIGN KEY(truk_id) REFERENCES truk(id) ON DELETE CASCADE
        )
      ''');
  }

  Future<void> _createTransactionTables(Database db) async {
    // lokasi_timbang
    await db.execute('''
        CREATE TABLE IF NOT EXISTS lokasi_timbang (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          jenis TEXT NOT NULL,
          alamat TEXT,
          aktif INTEGER NOT NULL DEFAULT 1,
          keterangan TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

    // panen
    await db.execute('''
        CREATE TABLE IF NOT EXISTS panen (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kebun_id INTEGER NOT NULL,
          tanggal TEXT NOT NULL,
          berat_bersih REAL NOT NULL,
          harga_sawit REAL NOT NULL,
          sortir REAL NOT NULL,
          shipping_method TEXT NOT NULL,
          lokasi_timbang_id INTEGER,
          keterangan TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE,
          FOREIGN KEY(lokasi_timbang_id) REFERENCES lokasi_timbang(id) ON DELETE SET NULL
        )
      ''');

    // panen_pekerja
    await db.execute('''
        CREATE TABLE IF NOT EXISTS panen_pekerja (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          panen_id INTEGER NOT NULL,
          pekerja_id INTEGER NOT NULL,
          UNIQUE(panen_id, pekerja_id),
          FOREIGN KEY(panen_id) REFERENCES panen(id) ON DELETE CASCADE,
          FOREIGN KEY(pekerja_id) REFERENCES pekerja(id) ON DELETE CASCADE
        )
      ''');

    // pengangkutan
    await db.execute('''
        CREATE TABLE IF NOT EXISTS pengangkutan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          panen_id INTEGER NOT NULL,
          truk_id INTEGER NOT NULL,
          berat_bersih REAL NOT NULL,
          keterangan TEXT,
          FOREIGN KEY(panen_id) REFERENCES panen(id) ON DELETE CASCADE,
          FOREIGN KEY(truk_id) REFERENCES truk(id) ON DELETE CASCADE
        )
      ''');

    // Indexes to speed up common lookups
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_panen_kebun_id ON panen(kebun_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_panen_lokasi_timbang_id ON panen(lokasi_timbang_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_panen_pekerja_panen_id ON panen_pekerja(panen_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_panen_pekerja_pekerja_id ON panen_pekerja(pekerja_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pengangkutan_panen_id ON pengangkutan(panen_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pengangkutan_truk_id ON pengangkutan(truk_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_kebun_truk_kebun_id ON kebun_truk(kebun_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_kebun_truk_truk_id ON kebun_truk(truk_id)',
    );
    await _createTarifAndBiayaTables(db);
  }

  Future<void> _createTarifAndBiayaTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tarif (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT NOT NULL,
        kebun_id INTEGER,
        nilai_per_kg REAL NOT NULL CHECK(nilai_per_kg >= 0),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(kebun_id) REFERENCES kebun(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS biaya_panen (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        panen_id INTEGER NOT NULL,
        jenis TEXT NOT NULL,
        tarif_per_kg REAL NOT NULL CHECK(tarif_per_kg >= 0),
        total_biaya REAL NOT NULL CHECK(total_biaya >= 0),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(panen_id, jenis),
        FOREIGN KEY(panen_id) REFERENCES panen(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pembayaran_biaya_panen (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        biaya_panen_id INTEGER NOT NULL,
        jumlah REAL NOT NULL CHECK(jumlah >= 0),
        tanggal TEXT NOT NULL,
        keterangan TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(biaya_panen_id) REFERENCES biaya_panen(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tarif_jenis_kebun ON tarif(jenis, kebun_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_biaya_panen_panen_id ON biaya_panen(panen_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pembayaran_biaya_panen_id ON pembayaran_biaya_panen(biaya_panen_id)',
    );
  }
}
