class Pengangkutan {
  final int? id;
  final int panenId;
  final int trukId;
  final double beratBersih;
  final String? keterangan;

  Pengangkutan({
    this.id,
    required this.panenId,
    required this.trukId,
    required this.beratBersih,
    this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'panen_id': panenId,
      'truk_id': trukId,
      'berat_bersih': beratBersih,
      'keterangan': keterangan,
    };
  }

  factory Pengangkutan.fromMap(Map<String, dynamic> map) {
    return Pengangkutan(
      id: map['id'] as int?,
      panenId: map['panen_id'] as int,
      trukId: map['truk_id'] as int,
      beratBersih: (map['berat_bersih'] as num).toDouble(),
      keterangan: map['keterangan'] as String?,
    );
  }
}
