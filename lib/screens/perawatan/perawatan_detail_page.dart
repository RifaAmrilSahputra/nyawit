import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';

const _green = Color(0xFF176B3A);

class PerawatanDetailPage extends StatefulWidget {
  const PerawatanDetailPage({super.key, required this.kegiatanId});
  final int kegiatanId;

  @override
  State<PerawatanDetailPage> createState() => _PerawatanDetailPageState();
}

class _PerawatanDetailPageState extends State<PerawatanDetailPage> {
  final _repo = KegiatanPerawatanRepository();
  late Future<KegiatanPerawatan?> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getById(widget.kegiatanId);
  }

  Future<void> _refresh() async =>
      setState(() => _future = _repo.getById(widget.kegiatanId));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        scrolledUnderElevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Detail Perawatan',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Refresh',
              onPressed: _refresh,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.primary,
              ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: FutureBuilder<KegiatanPerawatan?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            );
          }

          final k = snapshot.data;
          if (k == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final paymentStatus = k.statusPembayaran == 'lunas'
              ? 'Lunas'
              : k.statusPembayaran == 'kurang_bayar'
              ? 'Kurang bayar'
              : k.statusPembayaran == 'lebih_bayar'
              ? 'Lebih bayar'
              : 'Belum bayar';

          final statusColor = k.statusPembayaran == 'lunas'
              ? colors.primary
              : k.statusPembayaran == 'kurang_bayar'
              ? Colors.orange.shade700
              : k.statusPembayaran == 'lebih_bayar'
              ? Colors.blue.shade700
              : Colors.red.shade700;

          final statusBackground = k.statusPembayaran == 'lunas'
              ? const Color(0xFFE5F4EA)
              : k.statusPembayaran == 'kurang_bayar'
              ? const Color(0xFFFFF2DD)
              : k.statusPembayaran == 'lebih_bayar'
              ? const Color(0xFFE7F0FF)
              : const Color(0xFFFFE8E8);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: _green,
            backgroundColor: Colors.white,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              children: [
                _HeroCard(
                  title: k.namaKegiatan ?? k.jenis.label,
                  type: k.jenis.label,
                  total: _currency(k.totalBiaya),
                  paymentStatus: paymentStatus,
                  statusColor: statusColor,
                  statusBackground: statusBackground,
                ),
                const SizedBox(height: 14),
                _QuickSummary(
                  duration: '${k.durasiHari} hari',
                  quantity: k.jumlah == null
                      ? '—'
                      : '${k.jumlah!.toStringAsFixed(k.jumlah! % 1 == 0 ? 0 : 2)}${k.satuan != null ? ' ${k.satuan}' : ''}',
                  rate: k.tarifSatuan == null ? '—' : _currency(k.tarifSatuan!),
                ),
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Informasi kegiatan',
                  icon: Icons.assignment_rounded,
                  children: [
                    _DetailRow(
                      'Kebun',
                      'Kebun ${k.kebunId}',
                      icon: Icons.park_rounded,
                    ),
                    _DetailRow(
                      'Periode',
                      '${_formatDate(k.tanggalMulai)} - ${_formatDate(k.tanggalSelesai)}',
                      icon: Icons.calendar_month_rounded,
                    ),
                    _DetailRow(
                      'Durasi',
                      '${k.durasiHari} hari',
                      icon: Icons.schedule_rounded,
                    ),
                    if (k.jumlah != null)
                      _DetailRow(
                        'Jumlah',
                        '${k.jumlah!.toStringAsFixed(k.jumlah! % 1 == 0 ? 0 : 2)}${k.satuan != null ? ' ${k.satuan}' : ''}',
                        icon: Icons.straighten_rounded,
                      ),
                    _DetailRow(
                      'Tarif / satuan',
                      k.tarifSatuan == null ? '—' : _currency(k.tarifSatuan!),
                      icon: Icons.sell_rounded,
                    ),
                    _DetailRow(
                      'Keterangan',
                      k.keterangan?.trim().isNotEmpty == true
                          ? k.keterangan!
                          : '—',
                      icon: Icons.notes_rounded,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _PaymentSection(
                  dibayarkan: _currency(k.dibayarkan),
                  sisa: _currency(
                    (k.totalBiaya - k.dibayarkan).clamp(0, double.infinity),
                  ),
                  status: paymentStatus,
                  statusColor: statusColor,
                  statusBackground: statusBackground,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return date.toLocal().toIso8601String().split('T').first;
  }

  String _currency(num value) {
    return 'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.type,
    required this.total,
    required this.paymentStatus,
    required this.statusColor,
    required this.statusBackground,
  });

  final String title;
  final String type;
  final String total;
  final String paymentStatus;
  final Color statusColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.tertiary, .45)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  paymentStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .10)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Colors.white70,
                  size: 19,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Total biaya',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  const _QuickSummary({
    required this.duration,
    required this.quantity,
    required this.rate,
  });

  final String duration;
  final String quantity;
  final String rate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _SummaryItem(
            icon: Icons.schedule_rounded,
            label: 'Durasi',
            value: duration,
          ),
          _SummaryDivider(),
          _SummaryItem(
            icon: Icons.inventory_2_outlined,
            label: 'Jumlah',
            value: quantity,
          ),
          _SummaryDivider(),
          _SummaryItem(icon: Icons.sell_outlined, label: 'Tarif', value: rate),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 20),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F3E9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.icon, this.isLast = false});

  final String label;
  final String value;
  final IconData? icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: isLast ? 8 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon ?? Icons.circle_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 41, top: 10),
              child: Divider(height: 1, color: colors.outlineVariant),
            ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.dibayarkan,
    required this.sisa,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
  });

  final String dibayarkan;
  final String sisa;
  final String status;
  final Color statusColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F3E9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _PaymentRow(
                  label: 'Dibayarkan',
                  value: dibayarkan,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: 11),
                _PaymentRow(
                  label: 'Sisa',
                  value: sisa,
                  icon: Icons.account_balance_wallet_outlined,
                  valueColor: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: valueColor ?? colors.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}
