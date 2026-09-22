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

      if (mounted) {
        Navigator.of(context).pop(true);
      }
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
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Panen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Hapus panen',
              onPressed: _delete,
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                minimumSize: const Size(40, 40),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_PanenDetailData?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
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
            onRefresh: () async {
              setState(() => _future = _load());
            },
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
    final colors = Theme.of(context).colorScheme;
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
      color: colors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          _FinancialSummary(nilaiPanen: nilaiPanen, totalBiaya: totalBiaya),

          const SizedBox(height: 30),

          _SectionLabel(
            icon: Icons.agriculture_outlined,
            title: 'Informasi panen',
          ),
          const SizedBox(height: 8),

          _InfoGroup(
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
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.scale_outlined, title: 'Hasil panen'),
          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              _InfoRow('Berat bersih', '${_number(panen.beratBersih)} Kg'),
              _InfoRow('Harga sawit', _rupiah(panen.hargaSawit)),
              _InfoRow('Nilai panen', _rupiah(nilaiPanen), emphasize: true),
              _InfoRow('Sortir', '${_number(panen.sortir)} Kg', isLast: true),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.groups_outlined, title: 'Pekerja'),
          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              if (data.panenPekerja.isEmpty)
                const _EmptySection('Belum ada pekerja yang tercatat.')
              else
                ...data.panenPekerja.asMap().entries.map((entry) {
                  final isLast = entry.key == data.panenPekerja.length - 1;

                  return _ListRow(
                    icon: Icons.person_outline_rounded,
                    label: data.pekerjaName(entry.value.pekerjaId),
                    isLast: isLast,
                  );
                }),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(
            icon: Icons.local_shipping_outlined,
            title: 'Pengangkutan',
          ),
          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              if (panen.shippingMethod == ShippingMethod.antar) ...[
                if (data.pengangkutan.isEmpty)
                  const _EmptySection('Belum ada data pengangkutan.')
                else ...[
                  ...data.pengangkutan.asMap().entries.map((entry) {
                    final isLast = entry.key == data.pengangkutan.length - 1;

                    return _ListRow(
                      icon: Icons.local_shipping_outlined,
                      label: data.trukName(entry.value.trukId),
                      value: '${_number(entry.value.beratBersih)} Kg',
                      isLast: isLast,
                    );
                  }),
                  _InfoRow(
                    'Total pengangkutan',
                    '${_number(totalPengangkutan)} Kg',
                    emphasize: true,
                    isLast: true,
                  ),
                ],
              ] else
                const _EmptySection('Hasil panen ditimbang di lapangan.'),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.receipt_long_outlined, title: 'Biaya'),
          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              if (data.biaya.isEmpty)
                const _EmptySection(
                  'Belum ada snapshot biaya pada transaksi ini.',
                )
              else ...[
                ...data.biaya.asMap().entries.map((entry) {
                  final isLast = entry.key == data.biaya.length - 1;

                  return _BiayaRow(item: entry.value, isLast: isLast);
                }),
                _InfoRow(
                  'Total biaya',
                  _rupiah(totalBiaya),
                  emphasize: true,
                  isLast: true,
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.payments_outlined, title: 'Pembayaran'),
          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              if (data.biaya.isEmpty)
                const _EmptySection('Belum ada data pembayaran.')
              else
                ...data.biaya.asMap().entries.map((entry) {
                  return _PaymentRow(
                    item: entry.value,
                    isLast: entry.key == data.biaya.length - 1,
                  );
                }),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 19),
              label: const Text(
                'Edit Panen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummary extends StatelessWidget {
  const _FinancialSummary({required this.nilaiPanen, required this.totalBiaya});

  final double nilaiPanen;
  final double totalBiaya;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasilBersih = nilaiPanen - totalBiaya;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ringkasan keuangan',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SummaryValue(label: 'Nilai panen', value: _rupiah(nilaiPanen)),
          _SummaryValue(label: 'Total biaya', value: _rupiah(totalBiaya)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: colors.onPrimaryContainer.withValues(alpha: 0.12),
            ),
          ),

          _SummaryValue(
            label: 'Hasil bersih',
            value: _rupiah(hasilBersih),
            emphasize: true,
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onPrimaryContainer.withValues(alpha: 0.65),
                fontSize: 11.5,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontSize: emphasize ? 16 : 13,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: emphasize ? -0.2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
    this.label,
    this.value, {
    this.emphasize = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                    fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: emphasize ? 13 : 12.5,
                    fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                    color: colors.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 14,
            endIndent: 14,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.icon,
    required this.label,
    this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: colors.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 12),
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 57,
            endIndent: 14,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _BiayaRow extends StatelessWidget {
  const _BiayaRow({required this.item, this.isLast = false});

  final BiayaPanen item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 17,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _biayaName(item.jenis),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_rupiah(item.tarifPerKg)}/Kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _rupiah(item.totalBiaya),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 57,
            endIndent: 14,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.item, this.isLast = false});

  final BiayaPanen item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusColor = item.status == 'Lunas'
        ? colors.primary
        : item.status == 'Kurang Bayar'
        ? Colors.orange.shade800
        : Colors.blue.shade700;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _biayaName(item.jenis),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CompactPaymentRow(
                label: 'Total biaya',
                value: _rupiah(item.totalBiaya),
              ),
              _CompactPaymentRow(
                label: 'Dibayarkan',
                value: _rupiah(item.jumlahDibayarkan),
              ),
              _CompactPaymentRow(
                label: 'Selisih',
                value: _rupiah(item.jumlahDibayarkan - item.totalBiaya),
                emphasize: true,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 14,
            endIndent: 14,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _CompactPaymentRow extends StatelessWidget {
  const _CompactPaymentRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: colors.onSurface,
            ),
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailView extends StatelessWidget {
  const _EmptyDetailView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Data panen tidak ditemukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Coba lagi'),
      ),
    );
  }
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

  return '${days[value.weekday - 1]}, '
      '${value.day} ${months[value.month - 1]} ${value.year}';
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
