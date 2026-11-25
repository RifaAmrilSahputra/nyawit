import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/pembayaran_perawatan.dart';
import 'package:nyawit/models/status_kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';

part 'widgets/perawatan_detail_widgets.dart';

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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Text(
          'Detail Perawatan',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
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
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
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
            return Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            );
          }

          final paymentStatus = k.statusPembayaran == 'lunas'
              ? 'Lunas'
              : k.statusPembayaran == 'kurang_bayar'
              ? 'Sebagian / DP'
              : k.statusPembayaran == 'lebih_bayar'
              ? 'Lebih bayar'
              : 'Belum bayar';

          final statusColor = _paymentColor(k.statusPembayaran, colors);

          final statusBackground = _paymentBackground(
            k.statusPembayaran,
            colors,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            color: colors.primary,
            backgroundColor: colors.surfaceContainerHighest,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              children: [
                _HeroCard(
                  title: k.namaKegiatan ?? k.jenis.label,
                  type: k.jenis.label,
                  total: _currency(k.totalBiaya),
                  paymentStatus: paymentStatus,
                  statusColor: statusColor,
                  statusBackground: statusBackground,
                ),

                const SizedBox(height: 18),

                _QuickSummary(
                  duration: '${k.durasiHari} hari',
                  quantity: k.jumlah == null
                      ? '—'
                      : '${k.jumlah!.toStringAsFixed(k.jumlah! % 1 == 0 ? 0 : 2)}${k.satuan != null ? ' ${k.satuan}' : ''}',
                  rate: k.tarifSatuan == null ? '—' : _currency(k.tarifSatuan!),
                ),

                const SizedBox(height: 26),

                _ActivityInfoSection(
                  kebun: 'Kebun ${k.kebunId}',
                  startDate: k.tanggalMulai,
                  endDate: k.tanggalSelesai,
                  duration: '${k.durasiHari} hari',
                  quantity: k.jumlah == null
                      ? null
                      : '${k.jumlah!.toStringAsFixed(k.jumlah! % 1 == 0 ? 0 : 2)}${k.satuan != null ? ' ${k.satuan}' : ''}',
                  rate: k.tarifSatuan == null ? '—' : _currency(k.tarifSatuan!),
                  note: k.keterangan?.trim().isNotEmpty == true
                      ? k.keterangan!
                      : '—',
                ),

                const SizedBox(height: 26),

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

                FutureBuilder<List<StatusKegiatanPerawatan>>(
                  future: _statusHistoryFuture,
                  builder: (context, statusSnapshot) {
                    final history = statusSnapshot.data ?? const [];

                    if (history.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: _StatusHistorySection(history: history),
                    );
                  },
                ),

                const SizedBox(height: 26),

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

// ============================================================
// HELPERS
// ============================================================

Color _paymentColor(String? status, ColorScheme colors) {
  final isDark = colors.brightness == Brightness.dark;

  switch (status) {
    case 'lunas':
      return isDark ? const Color(0xFF66BB78) : const Color(0xFF2E7D32);

    case 'kurang_bayar':
      return isDark ? const Color(0xFFE5A93D) : const Color(0xFFD98E04);

    case 'lebih_bayar':
      return isDark ? const Color(0xFF69A5D8) : const Color(0xFF3D78B5);

    default:
      return isDark ? const Color(0xFFEF6B6B) : const Color(0xFFC84242);
  }
}

Color _paymentBackground(String? status, ColorScheme colors) {
  final isDark = colors.brightness == Brightness.dark;

  switch (status) {
    case 'lunas':
      return isDark ? const Color(0xFF183B24) : const Color(0xFFE5F4EA);

    case 'kurang_bayar':
      return isDark ? const Color(0xFF443617) : const Color(0xFFFFF2DD);

    case 'lebih_bayar':
      return isDark ? const Color(0xFF1C344A) : const Color(0xFFE7F0FF);

    default:
      return isDark ? const Color(0xFF451F1F) : const Color(0xFFFFE8E8);
  }
}

String _formatDateLong(DateTime date) {
  final local = date.toLocal();

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String _currency(num value) =>
    'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (match) => '.')}';
