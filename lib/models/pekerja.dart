class Pekerja {
  final int? id;
  final String nama;
  final String? noHp;
  final String? alamat;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pekerja({
    this.id,
    required this.nama,
    this.noHp,
    this.alamat,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_hp': noHp,
      'alamat': alamat,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Pekerja.fromMap(Map<String, dynamic> map) {
    return Pekerja(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      noHp: map['no_hp'] as String?,
      alamat: map['alamat'] as String?,
      status: map['status'] as String,
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
