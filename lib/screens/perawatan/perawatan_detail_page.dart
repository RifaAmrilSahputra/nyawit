import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/pembayaran_perawatan.dart';
import 'package:nyawit/models/status_kegiatan_perawatan.dart';
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
  final _paymentRepo = KegiatanPerawatanRepository();
  late Future<List<PembayaranPerawatan>> _paymentsFuture;
  late Future<List<StatusKegiatanPerawatan>> _statusHistoryFuture;

  @override
  void initState() {
    super.initState();
    _future = _repo.getById(widget.kegiatanId);
    _paymentsFuture = _repo.getPayments(widget.kegiatanId);
    _statusHistoryFuture = _repo.getStatusHistory(widget.kegiatanId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getById(widget.kegiatanId);
      _paymentsFuture = _repo.getPayments(widget.kegiatanId);
      _statusHistoryFuture = _repo.getStatusHistory(widget.kegiatanId);
    });
  }

  Future<void> _changeStatus(StatusKegiatan status) async {
    var tanggal = DateTime.now();
    final noteController = TextEditingController();
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Catat status ${status.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setDialogState) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Tanggal perubahan'),
                subtitle: Text(_formatDate(tanggal)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tanggal,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => tanggal = picked);
                  }
                },
              ),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, tanggal),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    final note = noteController.text.trim();
    noteController.dispose();
    if (result == null) return;
    await _repo.updateStatus(
      widget.kegiatanId,
      status,
      tanggal: result,
      keterangan: note.isEmpty ? null : note,
    );
    await _refresh();
  }

  Future<void> _addPayment(KegiatanPerawatan k) async {
    final amountController = TextEditingController(
      text:
          (k.totalDibayar < k.totalBiaya
                  ? k.totalBiaya - k.totalDibayar
                  : k.totalBiaya)
              .toStringAsFixed(0),
    );
    var tanggal = DateTime.now();
    var type = 'angsuran';
    final noteController = TextEditingController();
    final result = await showDialog<PembayaranPerawatan>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Tanggal pembayaran'),
                subtitle: Text(_formatDate(tanggal)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tanggal,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => tanggal = picked);
                  }
                },
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'dp', child: Text('DP')),
                  DropdownMenuItem(value: 'angsuran', child: Text('Angsuran')),
                  DropdownMenuItem(
                    value: 'pelunasan',
                    child: Text('Pelunasan'),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => type = value ?? type),
                decoration: const InputDecoration(labelText: 'Jenis'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.replaceAll(',', '.'),
                );
                if (amount == null || amount <= 0) return;
                final now = DateTime.now();
                Navigator.pop(
                  context,
                  PembayaranPerawatan(
                    kegiatanPerawatanId: k.id!,
                    tanggal: tanggal,
                    jumlah: amount,
                    jenis: type,
                    keterangan: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
    noteController.dispose();
    if (result != null) {
      await _paymentRepo.addPayment(result);
      await _refresh();
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
                backgroundColor: colors.surfaceContainerHighest,
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
              ? 'Sebagian / DP'
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
            backgroundColor: colors.surfaceContainerHighest,
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
                _WorkStatusSection(
                  status: k.statusKegiatan,
                  onStart: k.statusKegiatan == StatusKegiatan.rencana
                      ? () => _changeStatus(StatusKegiatan.dimulai)
                      : k.statusKegiatan == StatusKegiatan.dimulai
                      ? () => _changeStatus(StatusKegiatan.pengerjaan)
                      : null,
                  onComplete: k.statusKegiatan == StatusKegiatan.pengerjaan
                      ? () => _changeStatus(StatusKegiatan.selesai)
                      : null,
                ),
                const SizedBox(height: 14),
                FutureBuilder<List<StatusKegiatanPerawatan>>(
                  future: _statusHistoryFuture,
                  builder: (context, statusSnapshot) {
                    return _StatusHistorySection(
                      history: statusSnapshot.data ?? const [],
                    );
                  },
                ),
                const SizedBox(height: 14),
                FutureBuilder<List<PembayaranPerawatan>>(
                  future: _paymentsFuture,
                  builder: (context, paymentSnapshot) {
                    final payments = paymentSnapshot.data ?? const [];
                    return _PaymentSection(
                      total: _currency(k.totalBiaya),
                      dibayarkan: _currency(k.totalDibayar),
                      sisa: _currency(k.totalBiaya - k.totalDibayar),
                      status: paymentStatus,
                      statusColor: statusColor,
                      statusBackground: statusBackground,
                      payments: payments,
                      onAdd: () => _addPayment(k),
                    );
                  },
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
        color: colors.surfaceContainerLow,
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
        color: colors.surfaceContainerLow,
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
                  color: colors.secondaryContainer,
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

class _WorkStatusSection extends StatelessWidget {
  const _WorkStatusSection({
    required this.status,
    required this.onStart,
    required this.onComplete,
  });

  final StatusKegiatan status;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Status pengerjaan',
      icon: Icons.engineering_rounded,
      children: [
        _DetailRow(
          'Status',
          status.label,
          icon: Icons.flag_rounded,
          isLast: true,
        ),
        if (onStart != null)
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              status == StatusKegiatan.rencana
                  ? 'Mulai Pengerjaan'
                  : 'Tandai Pengerjaan',
            ),
          ),
        if (onComplete != null)
          FilledButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Tandai Selesai'),
          ),
      ],
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.total,
    required this.dibayarkan,
    required this.sisa,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.payments,
    required this.onAdd,
  });

  final String total;
  final String dibayarkan;
  final String sisa;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final List<PembayaranPerawatan> payments;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
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
                  color: colors.secondaryContainer,
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
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Pembayaran'),
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
                  label: 'Total Biaya',
                  value: total,
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 11),
                _PaymentRow(
                  label: 'Total Dibayar',
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
          if (payments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Riwayat pembayaran',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...payments.map(
              (payment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text(_currency(payment.jumlah)),
                subtitle: Text(
                  '${payment.jenis} - ${_formatDate(payment.tanggal)}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusHistorySection extends StatelessWidget {
  const _StatusHistorySection({required this.history});

  final List<StatusKegiatanPerawatan> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return _DetailSection(
      title: 'Riwayat pengerjaan',
      icon: Icons.history_rounded,
      children: history
          .map(
            (item) => _DetailRow(
              StatusKegiatanExtension.fromValue(item.status).label,
              '${_formatDate(item.tanggal)}${item.keterangan == null ? '' : '\n${item.keterangan}'}',
              icon: Icons.event_note_rounded,
              isLast: item == history.last,
            ),
          )
          .toList(),
    );
  }
}

String _formatDate(DateTime date) =>
    date.toLocal().toIso8601String().split('T').first;

String _currency(num value) =>
    'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (match) => '.')}';

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
