class KebunPekerja {
  final int? id;
  final int kebunId;
  final int pekerjaId;
  final bool isDefault;
  final bool aktif;
  final DateTime? mulai;
  final DateTime? selesai;
  final String? keterangan;

  KebunPekerja({
    this.id,
    required this.kebunId,
    required this.pekerjaId,
    required this.isDefault,
    required this.aktif,
    this.mulai,
    this.selesai,
    this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'pekerja_id': pekerjaId,
      'is_default': isDefault ? 1 : 0,
      'aktif': aktif ? 1 : 0,
      'mulai': mulai?.toIso8601String(),
      'selesai': selesai?.toIso8601String(),
      'keterangan': keterangan,
    };
  }

  factory KebunPekerja.fromMap(Map<String, dynamic> map) {
    return KebunPekerja(
      id: map['id'] as int?,
      kebunId: map['kebun_id'] as int,
      pekerjaId: map['pekerja_id'] as int,
      isDefault: (map['is_default'] as int) == 1,
      aktif: (map['aktif'] as int) == 1,
      mulai: map['mulai'] != null
          ? DateTime.parse(map['mulai'] as String)
          : null,
      selesai: map['selesai'] != null
          ? DateTime.parse(map['selesai'] as String)
          : null,
      keterangan: map['keterangan'] as String?,
    );
  }
}
