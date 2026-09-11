enum ShippingMethod { antar, lapangan }

class Panen {
  final int? id;
  final int kebunId;
  final DateTime tanggal;
  final double beratBersih;
  final double hargaSawit;
  final double sortir;
  final ShippingMethod shippingMethod;
  final int? lokasiTimbangId;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Panen({
    this.id,
    required this.kebunId,
    required this.tanggal,
    required this.beratBersih,
    required this.hargaSawit,
    required this.sortir,
    required this.shippingMethod,
    this.lokasiTimbangId,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kebun_id': kebunId,
      'tanggal': tanggal.toIso8601String(),
      'berat_bersih': beratBersih,
      'harga_sawit': hargaSawit,
      'sortir': sortir,
      'shipping_method': shippingMethod.name,
      'lokasi_timbang_id': lokasiTimbangId,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Panen.fromMap(Map<String, dynamic> map) {
    return Panen(
      id: map['id'] as int?,
      kebunId: map['kebun_id'] as int,
      tanggal: DateTime.parse(map['tanggal'] as String),
      beratBersih: (map['berat_bersih'] as num).toDouble(),
      hargaSawit: (map['harga_sawit'] as num).toDouble(),
      sortir: (map['sortir'] as num).toDouble(),
      shippingMethod: ShippingMethod.values.firstWhere(
        (item) => item.name == map['shipping_method'],
      ),
      lokasiTimbangId: map['lokasi_timbang_id'] as int?,
      keterangan: map['keterangan'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
