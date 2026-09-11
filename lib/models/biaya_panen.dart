import 'package:nyawit/models/tarif.dart';

class BiayaPanen {
  final int? id;
  final int panenId;
  final TarifJenis jenis;
  final double tarifPerKg;
  final double totalBiaya;
  final double jumlahDibayarkan;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BiayaPanen({
    this.id,
    required this.panenId,
    required this.jenis,
    required this.tarifPerKg,
    required this.totalBiaya,
    this.jumlahDibayarkan = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  double get selisih => jumlahDibayarkan - totalBiaya;
  String get status => selisih == 0
      ? 'Lunas'
      : selisih > 0
      ? 'Lebih Bayar'
      : 'Kurang Bayar';
  Map<String, dynamic> toMap() => {
    'id': id,
    'panen_id': panenId,
    'jenis': jenis.name,
    'tarif_per_kg': tarifPerKg,
    'total_biaya': totalBiaya,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  factory BiayaPanen.fromMap(Map<String, dynamic> map) => BiayaPanen(
    id: map['id'] as int?,
    panenId: map['panen_id'] as int,
    jenis: TarifJenis.values.firstWhere((e) => e.name == map['jenis']),
    tarifPerKg: (map['tarif_per_kg'] as num).toDouble(),
    totalBiaya: (map['total_biaya'] as num).toDouble(),
    jumlahDibayarkan: (map['jumlah_dibayarkan'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
