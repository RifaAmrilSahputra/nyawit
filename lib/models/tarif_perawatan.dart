enum JenisPerawatan { pupuk, tunas, semprot, lainnya }

extension JenisPerawatanExtension on JenisPerawatan {
  String get value {
    switch (this) {
      case JenisPerawatan.pupuk:
        return 'pupuk';
      case JenisPerawatan.tunas:
        return 'tunas';
      case JenisPerawatan.semprot:
        return 'semprot';
      case JenisPerawatan.lainnya:
        return 'lainnya';
    }
  }

  String get label {
    switch (this) {
      case JenisPerawatan.pupuk:
        return 'Pupuk';
      case JenisPerawatan.tunas:
        return 'Tunas';
      case JenisPerawatan.semprot:
        return 'Semprot';
      case JenisPerawatan.lainnya:
        return 'Lainnya';
    }
  }

  static JenisPerawatan fromValue(String value) {
    switch (value) {
      case 'pupuk':
        return JenisPerawatan.pupuk;
      case 'tunas':
        return JenisPerawatan.tunas;
      case 'semprot':
        return JenisPerawatan.semprot;
      case 'lainnya':
        return JenisPerawatan.lainnya;
      default:
        throw ArgumentError('Jenis perawatan tidak valid: $value');
    }
  }
}

class TarifPerawatan {
  final int? id;
  final int kebunId;
  final JenisPerawatan jenis;
  final int? produkId;
  final double tarif;
  final String satuan;
  final bool aktif;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TarifPerawatan({
    this.id,
    required this.kebunId,
    required this.jenis,
    this.produkId,
    required this.tarif,
    required this.satuan,
    this.aktif = true,
    required this.createdAt,
    required this.updatedAt,
  });

  TarifPerawatan copyWith({
    int? id,
    int? kebunId,
    JenisPerawatan? jenis,
    int? produkId,
    double? tarif,
    String? satuan,
    bool? aktif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TarifPerawatan(
      id: id ?? this.id,
      kebunId: kebunId ?? this.kebunId,
      jenis: jenis ?? this.jenis,
      produkId: produkId ?? this.produkId,
      tarif: tarif ?? this.tarif,
      satuan: satuan ?? this.satuan,
      aktif: aktif ?? this.aktif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'jenis': jenis.value,
      'produk_id': produkId,
      'tarif': tarif,
      'satuan': satuan,
      'aktif': aktif ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TarifPerawatan.fromMap(Map<String, dynamic> map) {
    return TarifPerawatan(
      id: map['id'] as int?,
      kebunId: map['kebun_id'] as int,
      jenis: JenisPerawatanExtension.fromValue(map['jenis'] as String),
      produkId: map['produk_id'] as int?,
      tarif: (map['tarif'] as num).toDouble(),
      satuan: map['satuan'] as String,
      aktif: (map['aktif'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
