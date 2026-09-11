class PembayaranPerawatan {
  final int? id;
  final int kegiatanPerawatanId;
  final DateTime tanggal;
  final double jumlah;
  final String jenis;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PembayaranPerawatan({
    this.id,
    required this.kegiatanPerawatanId,
    required this.tanggal,
    required this.jumlah,
    this.jenis = 'angsuran',
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'kegiatan_perawatan_id': kegiatanPerawatanId,
    'tanggal': tanggal.toIso8601String(),
    'jumlah': jumlah,
    'jenis': jenis,
    'keterangan': keterangan,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory PembayaranPerawatan.fromMap(Map<String, dynamic> map) {
    return PembayaranPerawatan(
      id: map['id'] as int?,
      kegiatanPerawatanId: map['kegiatan_perawatan_id'] as int,
      tanggal: DateTime.parse(map['tanggal'] as String),
      jumlah: (map['jumlah'] as num).toDouble(),
      jenis: map['jenis'] as String? ?? 'pembayaran',
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
