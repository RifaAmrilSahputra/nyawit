class PanenPekerja {
  final int? id;
  final int panenId;
  final int pekerjaId;

  PanenPekerja({this.id, required this.panenId, required this.pekerjaId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'panen_id': panenId, 'pekerja_id': pekerjaId};
  }

  factory PanenPekerja.fromMap(Map<String, dynamic> map) {
    return PanenPekerja(
      id: map['id'] as int?,
      panenId: map['panen_id'] as int,
      pekerjaId: map['pekerja_id'] as int,
    );
  }
}
