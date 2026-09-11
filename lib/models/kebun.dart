import 'package:nyawit/core/utils/date_time_parser.dart';

class Kebun {
  final int? id;
  final String nama;
  final String? lokasi;
  final double? luas;
  final int? jumlahPohon;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Kebun({
    this.id,
    required this.nama,
    this.lokasi,
    this.luas,
    this.jumlahPohon,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'lokasi': lokasi,
      'luas': luas,
      'jumlah_pohon': jumlahPohon,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Kebun.fromMap(Map<String, dynamic> map) {
    final fallback = DateTime.now();

    return Kebun(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      lokasi: map['lokasi'] as String?,
      luas: (map['luas'] as num?)?.toDouble(),
      jumlahPohon: (map['jumlah_pohon'] as num?)?.toInt(),
      keterangan: map['keterangan'] as String?,
      createdAt: parseDateTimeSafely(map['created_at'], fallback: fallback),
      updatedAt: parseDateTimeSafely(map['updated_at'], fallback: fallback),
    );
  }
}
