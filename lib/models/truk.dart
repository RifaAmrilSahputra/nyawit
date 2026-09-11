class Truk {
  final int? id;
  final String jenis;
  final String namaSupir;
  final String? noHp;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Truk({
    this.id,
    required this.jenis,
    required this.namaSupir,
    this.noHp,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'nama_supir': namaSupir,
      'no_hp': noHp,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Truk.fromMap(Map<String, dynamic> map) {
    return Truk(
      id: map['id'] as int?,
      jenis: map['jenis'] as String,
      namaSupir: map['nama_supir'] as String,
      noHp: map['no_hp'] as String?,
      status: map['status'] as String,
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
