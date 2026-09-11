import 'tarif_perawatan.dart';

enum StatusKegiatan { rencana, dimulai, pengerjaan, selesai, dibatalkan }

extension StatusKegiatanExtension on StatusKegiatan {
  String get value {
    switch (this) {
      case StatusKegiatan.rencana:
        return 'rencana';
      case StatusKegiatan.dimulai:
        return 'dimulai';
      case StatusKegiatan.pengerjaan:
        return 'pengerjaan';
      case StatusKegiatan.selesai:
        return 'selesai';
      case StatusKegiatan.dibatalkan:
        return 'dibatalkan';
    }
  }

  String get label {
    switch (this) {
      case StatusKegiatan.rencana:
        return 'Rencana';
      case StatusKegiatan.dimulai:
        return 'Dimulai';
      case StatusKegiatan.pengerjaan:
        return 'Pengerjaan';
      case StatusKegiatan.selesai:
        return 'Selesai';
      case StatusKegiatan.dibatalkan:
        return 'Dibatalkan';
    }
  }

  static StatusKegiatan fromValue(String value) {
    switch (value) {
      case 'rencana':
        return StatusKegiatan.rencana;
      case 'dimulai':
      case 'mulai':
        return StatusKegiatan.dimulai;
      case 'pengerjaan':
      case 'berlangsung':
        return StatusKegiatan.pengerjaan;
      case 'selesai':
        return StatusKegiatan.selesai;
      case 'dibatalkan':
        return StatusKegiatan.dibatalkan;
      default:
        throw ArgumentError('Status kegiatan tidak valid: $value');
    }
  }
}

class KegiatanPerawatan {
  final int? id;
  final int kebunId;
  final JenisPerawatan jenis;
  final String? namaKegiatan;

  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  final int? produkId;

  /// Jumlah pekerjaan.
  ///
  /// Pupuk  -> jumlah sak
  /// Tunas  -> jumlah pohon
  /// Semprot -> luas pekerjaan dalam ha
  /// Lainnya -> null
  final double? jumlah;

  final String? satuan;

  /// Snapshot tarif yang benar-benar digunakan
  /// pada saat transaksi dibuat.
  final double? tarifSatuan;

  /// Total biaya kegiatan.
  ///
  /// Pupuk   = jumlah × tarifSatuan
  /// Tunas   = jumlah × tarifSatuan
  /// Semprot = jumlah × tarifSatuan
  /// Lainnya = input manual
  final double totalBiaya;

  final double totalDibayar;

  final StatusKegiatan statusKegiatan;
  final String? keterangan;

  final DateTime createdAt;
  final DateTime updatedAt;

  const KegiatanPerawatan({
    this.id,
    required this.kebunId,
    required this.jenis,
    this.namaKegiatan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.produkId,
    this.jumlah,
    this.satuan,
    this.tarifSatuan,
    required this.totalBiaya,
    this.totalDibayar = 0,
    this.statusKegiatan = StatusKegiatan.rencana,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Selisih pembayaran.
  ///
  /// Negatif  = kurang bayar
  /// 0        = lunas
  /// Positif  = lebih bayar
  double get selisihPembayaran {
    return totalDibayar - totalBiaya;
  }

  /// Status pembayaran dihitung, bukan disimpan di database.
  String get statusPembayaran {
    if (totalDibayar == 0) {
      return 'belum_dibayar';
    }

    if (totalDibayar < totalBiaya) {
      return 'kurang_bayar';
    }

    if (totalDibayar == totalBiaya) {
      return 'lunas';
    }

    return 'lebih_bayar';
  }

  int get durasiHari {
    return tanggalSelesai.difference(tanggalMulai).inDays + 1;
  }

  KegiatanPerawatan copyWith({
    int? id,
    int? kebunId,
    JenisPerawatan? jenis,
    String? namaKegiatan,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    int? produkId,
    double? jumlah,
    String? satuan,
    double? tarifSatuan,
    double? totalBiaya,
    double? totalDibayar,
    StatusKegiatan? statusKegiatan,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KegiatanPerawatan(
      id: id ?? this.id,
      kebunId: kebunId ?? this.kebunId,
      jenis: jenis ?? this.jenis,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      produkId: produkId ?? this.produkId,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      tarifSatuan: tarifSatuan ?? this.tarifSatuan,
      totalBiaya: totalBiaya ?? this.totalBiaya,
      totalDibayar: totalDibayar ?? this.totalDibayar,
      statusKegiatan: statusKegiatan ?? this.statusKegiatan,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'jenis': jenis.value,
      'nama_kegiatan': namaKegiatan,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
      'produk_id': produkId,
      'jumlah': jumlah,
      'satuan': satuan,
      'tarif_satuan': tarifSatuan,
      'total_biaya': totalBiaya,
      // Kept for backward-compatible reads; new payments use their own table.
      'dibayarkan': 0,
      'status_kegiatan': statusKegiatan.value,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory KegiatanPerawatan.fromMap(Map<String, dynamic> map) {
    return KegiatanPerawatan(
      id: map['id'] as int?,
      kebunId: map['kebun_id'] as int,
      jenis: JenisPerawatanExtension.fromValue(map['jenis'] as String),
      namaKegiatan: map['nama_kegiatan'] as String?,
      tanggalMulai: DateTime.parse(map['tanggal_mulai'] as String),
      tanggalSelesai: DateTime.parse(map['tanggal_selesai'] as String),
      produkId: map['produk_id'] as int?,
      jumlah: map['jumlah'] == null ? null : (map['jumlah'] as num).toDouble(),
      satuan: map['satuan'] as String?,
      tarifSatuan: map['tarif_satuan'] == null
          ? null
          : (map['tarif_satuan'] as num).toDouble(),
      totalBiaya: (map['total_biaya'] as num).toDouble(),
      totalDibayar:
          (map['total_dibayar'] as num?)?.toDouble() ??
          (map['dibayarkan'] as num?)?.toDouble() ??
          0,
      statusKegiatan: StatusKegiatanExtension.fromValue(
        map['status_kegiatan'] as String,
      ),
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
