class StatusKegiatanPerawatan {
  final int? id;
  final int kegiatanPerawatanId;
  final String status;
  final DateTime tanggal;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StatusKegiatanPerawatan({
    this.id,
    required this.kegiatanPerawatanId,
    required this.status,
    required this.tanggal,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'kegiatan_perawatan_id': kegiatanPerawatanId,
    'status': status,
    'tanggal': tanggal.toIso8601String(),
    'keterangan': keterangan,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory StatusKegiatanPerawatan.fromMap(Map<String, dynamic> map) {
    return StatusKegiatanPerawatan(
      id: map['id'] as int?,
      kegiatanPerawatanId: map['kegiatan_perawatan_id'] as int,
      status: map['status'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
