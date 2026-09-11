enum TarifJenis { upahPanen, ongkosTruk, biayaMuat }

class Tarif {
  final int? id;
  final TarifJenis jenis;
  final int? kebunId;
  final double nilaiPerKg;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tarif({
    this.id,
    required this.jenis,
    this.kebunId,
    required this.nilaiPerKg,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'jenis': jenis.name,
    'kebun_id': kebunId,
    'nilai_per_kg': nilaiPerKg,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  factory Tarif.fromMap(Map<String, dynamic> map) => Tarif(
    id: map['id'] as int?,
    jenis: TarifJenis.values.firstWhere((e) => e.name == map['jenis']),
    kebunId: map['kebun_id'] as int?,
    nilaiPerKg: (map['nilai_per_kg'] as num).toDouble(),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
