class Produk {
  final int? id;
  final String nama;
  final String jenis;
  final String satuanDefault;
  final bool aktif;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Produk({
    this.id,
    required this.nama,
    required this.jenis,
    required this.satuanDefault,
    this.aktif = true,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Produk copyWith({
    int? id,
    String? nama,
    String? jenis,
    String? satuanDefault,
    bool? aktif,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produk(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      satuanDefault: satuanDefault ?? this.satuanDefault,
      aktif: aktif ?? this.aktif,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis': jenis,
      'satuan_default': satuanDefault,
      'aktif': aktif ? 1 : 0,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      jenis: map['jenis'] as String,
      satuanDefault: map['satuan_default'] as String,
      aktif: (map['aktif'] as int? ?? 1) == 1,
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
