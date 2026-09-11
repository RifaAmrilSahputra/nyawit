import 'package:flutter_test/flutter_test.dart';
import 'package:nyawit/models/biaya_panen.dart';
import 'package:nyawit/models/tarif.dart';

void main() {
  BiayaPanen biaya(double dibayar) => BiayaPanen(
    panenId: 1,
    jenis: TarifJenis.upahPanen,
    tarifPerKg: 150,
    totalBiaya: 270000,
    jumlahDibayarkan: dibayar,
    createdAt: DateTime(2026, 8, 30),
    updatedAt: DateTime(2026, 8, 30),
  );

  test('status pembayaran mengikuti selisih terhadap total biaya', () {
    expect(biaya(250000).status, 'Kurang Bayar');
    expect(biaya(270000).status, 'Lunas');
    expect(biaya(280000).status, 'Lebih Bayar');
    expect(biaya(280000).selisih, 10000);
  });
}
