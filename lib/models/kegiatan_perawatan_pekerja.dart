class KegiatanPerawatanPekerja {
  final int? id;
  final int kegiatanPerawatanId;
  final int pekerjaId;

  const KegiatanPerawatanPekerja({
    this.id,
    required this.kegiatanPerawatanId,
    required this.pekerjaId,
  });

  KegiatanPerawatanPekerja copyWith({
    int? id,
    int? kegiatanPerawatanId,
    int? pekerjaId,
  }) {
    return KegiatanPerawatanPekerja(
      id: id ?? this.id,
      kegiatanPerawatanId: kegiatanPerawatanId ?? this.kegiatanPerawatanId,
      pekerjaId: pekerjaId ?? this.pekerjaId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kegiatan_perawatan_id': kegiatanPerawatanId,
      'pekerja_id': pekerjaId,
    };
  }

  factory KegiatanPerawatanPekerja.fromMap(Map<String, dynamic> map) {
    return KegiatanPerawatanPekerja(
      id: map['id'] as int?,
      kegiatanPerawatanId: map['kegiatan_perawatan_id'] as int,
      pekerjaId: map['pekerja_id'] as int,
    );
  }
}
