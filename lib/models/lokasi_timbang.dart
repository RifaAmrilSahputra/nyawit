enum WeighbridgeType { ram, lapangan }

class LokasiTimbang {
  final int? id;
  final String nama;
  final WeighbridgeType jenis;
  final String? alamat;
  final bool aktif;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  LokasiTimbang({
    this.id,
    required this.nama,
    required this.jenis,
    this.alamat,
    required this.aktif,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis': jenis.name,
      'alamat': alamat,
      'aktif': aktif ? 1 : 0,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LokasiTimbang.fromMap(Map<String, dynamic> map) {
    return LokasiTimbang(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      jenis: WeighbridgeType.values.firstWhere(
        (item) => item.name == map['jenis'],
      ),
      alamat: map['alamat'] as String?,
      aktif: (map['aktif'] as int) == 1,
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
