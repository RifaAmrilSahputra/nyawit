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

const _darkForest = Color(0xFF123B2D);
const _darkForestHighlight = Color(0xFF205640);

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
            letterSpacing: -0.3,
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
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          _FinancialSummary(nilaiPanen: nilaiPanen, totalBiaya: totalBiaya),

          const SizedBox(height: 32),

          _SectionTitle(
            icon: Icons.agriculture_outlined,
            title: 'Informasi Panen',
          ),

          const SizedBox(height: 12),

          _HarvestInformation(data: data),

          const SizedBox(height: 32),

          _SectionTitle(icon: Icons.scale_outlined, title: 'Hasil Panen'),

          const SizedBox(height: 12),

          _HarvestMetrics(panen: panen, nilaiPanen: nilaiPanen),

          const SizedBox(height: 32),

          _SectionTitle(icon: Icons.groups_outlined, title: 'Pekerja'),

          const SizedBox(height: 12),

          _WorkersSection(data: data),

          const SizedBox(height: 32),

          _SectionTitle(
            icon: Icons.local_shipping_outlined,
            title: 'Pengangkutan',
          ),

          const SizedBox(height: 12),

          _TransportationSection(
            data: data,
            panen: panen,
            totalPengangkutan: totalPengangkutan,
          ),

          const SizedBox(height: 32),

          _SectionTitle(icon: Icons.receipt_long_outlined, title: 'Biaya'),

          const SizedBox(height: 12),

          _CostSection(data: data, totalBiaya: totalBiaya),

          const SizedBox(height: 32),

          _SectionTitle(icon: Icons.payments_outlined, title: 'Pembayaran'),

          const SizedBox(height: 12),

          _PaymentSection(data: data),

          const SizedBox(height: 32),

          SizedBox(
            height: 58,
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 19),
              label: const Text(
                'Edit Panen',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FINANCIAL SUMMARY
// ============================================================

class _FinancialSummary extends StatelessWidget {
  const _FinancialSummary({required this.nilaiPanen, required this.totalBiaya});

  final double nilaiPanen;
  final double totalBiaya;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasilBersih = nilaiPanen - totalBiaya;
    final summaryTextColor = isDark ? Colors.white : colors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: isDark ? null : colors.primaryContainer,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_darkForest, _darkForestHighlight],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                'Ringkasan keuangan',
                style: TextStyle(
                  color: summaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'HASIL BERSIH',
            style: TextStyle(
              color: summaryTextColor.withValues(alpha: 0.70),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _rupiah(hasilBersih),
              style: TextStyle(
                color: summaryTextColor,
                fontSize: 30,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Container(height: 1, color: summaryTextColor.withValues(alpha: 0.18)),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _FinancialSecondaryValue(
                  label: 'Nilai panen',
                  value: _rupiah(nilaiPanen),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FinancialSecondaryValue(
                  label: 'Total biaya',
                  value: _rupiah(totalBiaya),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialSecondaryValue extends StatelessWidget {
  const _FinancialSecondaryValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onPrimaryContainer.withValues(alpha: 0.58),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

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
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFORMASI PANEN
// ============================================================

class _HarvestInformation extends StatelessWidget {
  const _HarvestInformation({required this.data});

  final _PanenDetailData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final panen = data.panen;

    final kebunName = data.kebun?.nama ?? 'Kebun tidak ditemukan';

    final keterangan = panen.keterangan?.trim().isNotEmpty == true
        ? panen.keterangan!
        : '—';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kebunName,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _formatDate(panen.tanggal),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),

          const SizedBox(height: 16),

          _CompactInfoRow(
            label: 'Metode',
            value: panen.shippingMethod == ShippingMethod.antar
                ? 'Antar'
                : 'Lapangan',
          ),

          const SizedBox(height: 13),

          _CompactInfoRow(label: 'Lokasi timbang', value: data.lokasiName),

          const SizedBox(height: 13),

          _CompactInfoRow(label: 'Keterangan', value: keterangan),
        ],
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HASIL PANEN
// ============================================================

class _HarvestMetrics extends StatelessWidget {
  const _HarvestMetrics({required this.panen, required this.nilaiPanen});

  final Panen panen;
  final double nilaiPanen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'BERAT BERSIH',
                  value: '${_number(panen.beratBersih)} Kg',
                ),
              ),
              Container(
                width: 1,
                height: 84,
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
              Expanded(
                child: _MetricItem(
                  label: 'HARGA SAWIT',
                  value: _rupiah(panen.hargaSawit),
                  alignEnd: true,
                ),
              ),
            ],
          ),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),

          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'SORTIR',
                  value: '${_number(panen.sortir)} Kg',
                ),
              ),
              Container(
                width: 1,
                height: 84,
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
              Expanded(
                child: _MetricItem(
                  label: 'NILAI PANEN',
                  value: _rupiah(nilaiPanen),
                  emphasize: true,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 7),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: emphasize ? 17 : 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PEKERJA
// ============================================================

class _WorkersSection extends StatelessWidget {
  const _WorkersSection({required this.data});

  final _PanenDetailData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (data.panenPekerja.isEmpty) {
      return _MinimalEmptyState(
        icon: Icons.person_outline_rounded,
        message: 'Belum ada pekerja yang tercatat.',
      );
    }

    final count = data.panenPekerja.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Tim panen',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                '$count orang',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: data.panenPekerja.map((item) {
              final name = data.pekerjaName(item.pekerjaId);

              return _WorkerChip(name: name);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WorkerChip extends StatelessWidget {
  const _WorkerChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PENGANGKUTAN
// ============================================================

class _TransportationSection extends StatelessWidget {
  const _TransportationSection({
    required this.data,
    required this.panen,
    required this.totalPengangkutan,
  });

  final _PanenDetailData data;
  final Panen panen;
  final double totalPengangkutan;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (panen.shippingMethod == ShippingMethod.lapangan) {
      return _MinimalEmptyState(
        icon: Icons.scale_outlined,
        message: 'Hasil panen ditimbang di lapangan.',
      );
    }

    if (data.pengangkutan.isEmpty) {
      return _MinimalEmptyState(
        icon: Icons.local_shipping_outlined,
        message: 'Belum ada data pengangkutan.',
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...data.pengangkutan.asMap().entries.map((entry) {
            return _TransportationItem(
              label: data.trukName(entry.value.trukId),
              weight: '${_number(entry.value.beratBersih)} Kg',
              isLast: entry.key == data.pengangkutan.length - 1,
            );
          }),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PENGANGKUTAN',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Berat bersih seluruh kendaraan',
                      style: TextStyle(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${_number(totalPengangkutan)} Kg',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransportationItem extends StatelessWidget {
  const _TransportationItem({
    required this.label,
    required this.weight,
    required this.isLast,
  });

  final String label;
  final String weight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 19,
              color: colors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(width: 12),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              weight,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BIAYA
// ============================================================

class _CostSection extends StatelessWidget {
  const _CostSection({required this.data, required this.totalBiaya});

  final _PanenDetailData data;
  final double totalBiaya;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (data.biaya.isEmpty) {
      return _MinimalEmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada snapshot biaya pada transaksi ini.',
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...data.biaya.asMap().entries.map((entry) {
            return _CostItem(
              item: entry.value,
              isLast: entry.key == data.biaya.length - 1,
            );
          }),

          const SizedBox(height: 5),

          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.38),
          ),

          const SizedBox(height: 17),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BIAYA',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seluruh biaya transaksi',
                      style: TextStyle(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _rupiah(totalBiaya),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostItem extends StatelessWidget {
  const _CostItem({required this.item, required this.isLast});

  final BiayaPanen item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 18,
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
                    color: colors.onSurface,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_rupiah(item.tarifPerKg)}/Kg',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _rupiah(item.totalBiaya),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PEMBAYARAN
// ============================================================

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.data});

  final _PanenDetailData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (data.biaya.isEmpty) {
      return _MinimalEmptyState(
        icon: Icons.payments_outlined,
        message: 'Belum ada data pembayaran.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: data.biaya.asMap().entries.map((entry) {
          return _PaymentItem(
            item: entry.value,
            isLast: entry.key == data.biaya.length - 1,
          );
        }).toList(),
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  const _PaymentItem({required this.item, required this.isLast});

  final BiayaPanen item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = item.status == 'Lunas'
        ? colors.primary
        : item.status == 'Kurang Bayar'
        ? isDark
              ? const Color(0xFFF1CC75)
              : Colors.orange.shade800
        : isDark
        ? const Color(0xFF90CAF9)
        : Colors.blue.shade700;

    final difference = item.jumlahDibayarkan - item.totalBiaya;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, isLast ? 18 : 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _biayaName(item.jenis),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              _PaymentStatusBadge(status: item.status, color: statusColor),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'DIBAYARKAN',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),

          const SizedBox(height: 4),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _rupiah(item.jumlahDibayarkan),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'dari total biaya ${_rupiah(item.totalBiaya)}',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 17),

          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Selisih',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _rupiah(difference),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _MinimalEmptyState extends StatelessWidget {
  const _MinimalEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY DETAIL
// ============================================================

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

// ============================================================
// ERROR
// ============================================================

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

// ============================================================
// HELPERS
// ============================================================

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
