import 'package:flutter/material.dart';
import 'package:nyawit/models/biaya_panen.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/models/panen_pekerja.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/pengangkutan.dart';
import 'package:nyawit/models/tarif.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/repositories/biaya_panen_repository.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/lokasi_timbang_repository.dart';
import 'package:nyawit/repositories/panen_pekerja_repository.dart';
import 'package:nyawit/repositories/panen_repository.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/pengangkutan_repository.dart';
import 'package:nyawit/repositories/truk_repository.dart';
import 'package:nyawit/screens/panen/panen_form_page.dart';

const _green = Color(0xFF176B3A);

class PanenDetailPage extends StatefulWidget {
  const PanenDetailPage({super.key, required this.panenId});

  final int panenId;

  @override
  State<PanenDetailPage> createState() => _PanenDetailPageState();
}

class _PanenDetailPageState extends State<PanenDetailPage> {
  final _panenRepository = PanenRepository();
  final _kebunRepository = KebunRepository();
  final _pekerjaRepository = PekerjaRepository();
  final _trukRepository = TrukRepository();
  final _lokasiRepository = LokasiTimbangRepository();
  final _panenPekerjaRepository = PanenPekerjaRepository();
  final _pengangkutanRepository = PengangkutanRepository();
  final _biayaRepository = BiayaPanenRepository();
  late Future<_PanenDetailData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PanenDetailData?> _load() async {
    final panen = await _panenRepository.getById(widget.panenId);
    if (panen == null) return null;
    final values = await Future.wait([
      _kebunRepository.getById(panen.kebunId),
      _pekerjaRepository.getAll(),
      _trukRepository.getAll(),
      _lokasiRepository.getAll(),
      _panenPekerjaRepository.getByPanenId(widget.panenId),
      _pengangkutanRepository.getByPanenId(widget.panenId),
      _biayaRepository.getByPanenId(widget.panenId),
    ]);
    return _PanenDetailData(
      panen: panen,
      kebun: values[0] as Kebun?,
      pekerja: values[1] as List<Pekerja>,
      truk: values[2] as List<Truk>,
      lokasi: values[3] as List<LokasiTimbang>,
      panenPekerja: values[4] as List<PanenPekerja>,
      pengangkutan: values[5] as List<Pengangkutan>,
      biaya: values[6] as List<BiayaPanen>,
    );
  }

  Future<void> _edit(Panen panen) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PanenFormPage(panen: panen)),
    );
    if (changed == true && mounted) {
      setState(() => _future = _load());
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus panen?'),
        content: const Text(
          'Data pekerja, pengangkutan, biaya, dan pembayaran transaksi ini juga akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _panenRepository.delete(widget.panenId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus transaksi panen.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detail Panen',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus panen',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_PanenDetailData?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: () => setState(() => _future = _load()));
          }
          final data = snapshot.data;
          if (data == null) {
            return const _EmptyDetailView();
          }
          return _DetailBody(
            data: data,
            onEdit: () => _edit(data.panen),
            onRefresh: () async => setState(() => _future = _load()),
          );
        },
      ),
    );
  }
}

class _PanenDetailData {
  const _PanenDetailData({
    required this.panen,
    required this.kebun,
    required this.pekerja,
    required this.truk,
    required this.lokasi,
    required this.panenPekerja,
    required this.pengangkutan,
    required this.biaya,
  });

  final Panen panen;
  final Kebun? kebun;
  final List<Pekerja> pekerja;
  final List<Truk> truk;
  final List<LokasiTimbang> lokasi;
  final List<PanenPekerja> panenPekerja;
  final List<Pengangkutan> pengangkutan;
  final List<BiayaPanen> biaya;

  String pekerjaName(int id) =>
      pekerja
          .where((item) => item.id == id)
          .map((item) => item.nama)
          .firstOrNull ??
      'Pekerja tidak ditemukan';

  String trukName(int id) =>
      truk
          .where((item) => item.id == id)
          .map((item) => '${item.jenis} — ${item.namaSupir}')
          .firstOrNull ??
      'Truk tidak ditemukan';

  String get lokasiName =>
      lokasi
          .where((item) => item.id == panen.lokasiTimbangId)
          .map((item) => item.nama)
          .firstOrNull ??
      'Tidak dicatat';
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.data,
    required this.onEdit,
    required this.onRefresh,
  });

  final _PanenDetailData data;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final panen = data.panen;
    final nilaiPanen = panen.beratBersih * panen.hargaSawit;
    final totalBiaya = data.biaya.fold<double>(
      0,
      (sum, item) => sum + item.totalBiaya,
    );
    final totalPengangkutan = data.pengangkutan.fold<double>(
      0,
      (sum, item) => sum + item.beratBersih,
    );
    return RefreshIndicator(
      color: _green,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SummaryCard(nilaiPanen: nilaiPanen, totalBiaya: totalBiaya),
          const SizedBox(height: 16),
          _Section(
            title: 'Informasi Panen',
            icon: Icons.agriculture_rounded,
            child: Column(
              children: [
                _InfoRow('Kebun', data.kebun?.nama ?? 'Kebun tidak ditemukan'),
                _InfoRow('Hari, tanggal', _formatDate(panen.tanggal)),
                _InfoRow(
                  'Metode',
                  panen.shippingMethod == ShippingMethod.antar
                      ? 'Antar'
                      : 'Lapangan',
                ),
                _InfoRow('Lokasi timbang', data.lokasiName),
                _InfoRow(
                  'Keterangan',
                  panen.keterangan?.trim().isNotEmpty == true
                      ? panen.keterangan!
                      : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Hasil Panen',
            icon: Icons.scale_rounded,
            child: Column(
              children: [
                _InfoRow('Berat bersih', '${_number(panen.beratBersih)} Kg'),
                _InfoRow('Harga sawit', _rupiah(panen.hargaSawit)),
                _InfoRow('Nilai panen', _rupiah(nilaiPanen), emphasize: true),
                _InfoRow('Sortir', '${_number(panen.sortir)} Kg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Pekerja',
            icon: Icons.groups_rounded,
            child: data.panenPekerja.isEmpty
                ? const _EmptySection('Belum ada pekerja yang tercatat.')
                : Column(
                    children: data.panenPekerja
                        .map(
                          (item) => _ListRow(
                            icon: Icons.person_rounded,
                            label: data.pekerjaName(item.pekerjaId),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 12),
          if (panen.shippingMethod == ShippingMethod.antar)
            _Section(
              title: 'Pengangkutan',
              icon: Icons.local_shipping_rounded,
              child: data.pengangkutan.isEmpty
                  ? const _EmptySection('Belum ada data pengangkutan.')
                  : Column(
                      children: [
                        ...data.pengangkutan.map(
                          (item) => _ListRow(
                            icon: Icons.local_shipping_rounded,
                            label: data.trukName(item.trukId),
                            value: '${_number(item.beratBersih)} Kg',
                          ),
                        ),
                        const Divider(height: 22),
                        _InfoRow(
                          'Total pengangkutan',
                          '${_number(totalPengangkutan)} Kg',
                          emphasize: true,
                        ),
                      ],
                    ),
            )
          else
            const _Section(
              title: 'Pengangkutan',
              icon: Icons.landscape_rounded,
              child: _EmptySection('Hasil panen ditimbang di lapangan.'),
            ),
          const SizedBox(height: 12),
          _Section(
            title: 'Biaya',
            icon: Icons.receipt_long_rounded,
            child: data.biaya.isEmpty
                ? const _EmptySection(
                    'Belum ada snapshot biaya pada transaksi ini.',
                  )
                : Column(
                    children: [
                      ...data.biaya.map((item) => _BiayaRow(item: item)),
                      const Divider(height: 22),
                      _InfoRow(
                        'Total biaya',
                        _rupiah(totalBiaya),
                        emphasize: true,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Pembayaran',
            icon: Icons.payments_rounded,
            child: data.biaya.isEmpty
                ? const _EmptySection('Belum ada data pembayaran.')
                : Column(
                    children: data.biaya
                        .map((item) => _PaymentRow(item: item))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Panen'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.nilaiPanen, required this.totalBiaya});
  final double nilaiPanen;
  final double totalBiaya;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _green,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: _green.withValues(alpha: 0.16),
          blurRadius: 22,
          offset: const Offset(0, 9),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Keuangan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        _SummaryValue(label: 'Nilai Panen', value: _rupiah(nilaiPanen)),
        _SummaryValue(label: 'Total Biaya', value: _rupiah(totalBiaya)),
        const Divider(color: Colors.white24, height: 24),
        _SummaryValue(
          label: 'Hasil Bersih',
          value: _rupiah(nilaiPanen - totalBiaya),
          emphasize: true,
        ),
      ],
    ),
  );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
  final String label;
  final String value;
  final bool emphasize;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            fontSize: emphasize ? 16 : 14,
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE3E9E4)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _green, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.icon, required this.label, this.value});
  final IconData icon;
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (value != null)
          Text(value!, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _BiayaRow extends StatelessWidget {
  const _BiayaRow({required this.item});
  final BiayaPanen item;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _biayaName(item.jenis),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              _rupiah(item.totalBiaya),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${_rupiah(item.tarifPerKg)}/Kg',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.item});
  final BiayaPanen item;
  @override
  Widget build(BuildContext context) {
    final statusColor = item.status == 'Lunas'
        ? _green
        : item.status == 'Kurang Bayar'
        ? Colors.orange.shade800
        : Colors.blue.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _biayaName(item.jenis),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Chip(
                label: Text(item.status),
                labelStyle: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _InfoRow('Total biaya', _rupiah(item.totalBiaya)),
          _InfoRow('Dibayarkan', _rupiah(item.jumlahDibayarkan)),
          _InfoRow(
            'Selisih',
            _rupiah(item.jumlahDibayarkan - item.totalBiaya),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Text(
    message,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 13,
    ),
  );
}

class _EmptyDetailView extends StatelessWidget {
  const _EmptyDetailView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Data panen tidak ditemukan.'));
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
  );
}

String _biayaName(TarifJenis jenis) => switch (jenis) {
  TarifJenis.upahPanen => 'Upah Panen',
  TarifJenis.ongkosTruk => 'Ongkos Truk',
  TarifJenis.biayaMuat => 'Biaya Muat',
};

String _formatDate(DateTime value) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year}';
}

String _rupiah(double value) => 'Rp ${_number(value)}';

String _number(num value) {
  final text = value.toDouble() == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  final parts = text.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return parts.length == 1 ? whole : '$whole,${parts.last}';
}
