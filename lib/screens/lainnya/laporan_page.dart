import 'package:flutter/material.dart';
import 'package:nyawit/models/dashboard_overview.dart';
import 'package:nyawit/repositories/dashboard_repository.dart';
import 'package:nyawit/screens/lainnya/widgets/laporan_widgets.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key, this.loadOverview});

  final Future<DashboardOverview> Function()? loadOverview;

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  late Future<DashboardOverview> _overview;

  Future<DashboardOverview> _load() {
    return widget.loadOverview?.call() ?? DashboardRepository().loadOverview();
  }

  @override
  void initState() {
    super.initState();
    _overview = _load();
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _overview = future);
    await future;
  }

  void _retry() {
    setState(() => _overview = _load());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Laporan',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<DashboardOverview>(
        future: _overview,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: colors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Laporan gagal dimuat. Periksa data lalu coba lagi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                'Laporan belum tersedia.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
              children: [
                LaporanHeroCard(monthLabel: data.monthLabel),
                const SizedBox(height: 18),
                LaporanSectionHeader(
                  title: 'Ringkasan ${data.monthLabel}',
                  subtitle: 'Rekap hasil dan pengeluaran bulan berjalan',
                  icon: Icons.summarize_rounded,
                ),
                const SizedBox(height: 12),
                LaporanSummaryGrid(data: data),
                const SizedBox(height: 22),
                const LaporanSectionHeader(
                  title: 'Tren 7 bulan',
                  subtitle: 'Produksi, pendapatan, dan biaya',
                  icon: Icons.show_chart_rounded,
                ),
                const SizedBox(height: 12),
                LaporanTrendCard(data: data),
                const SizedBox(height: 22),
                const LaporanSectionHeader(
                  title: 'Performa kebun',
                  subtitle: 'Kontribusi produksi panen bulan ini',
                  icon: Icons.forest_rounded,
                ),
                const SizedBox(height: 12),
                LaporanGardenCard(gardens: data.gardenPerformance),
                const SizedBox(height: 22),
                const LaporanSectionHeader(
                  title: 'Distribusi biaya',
                  subtitle: 'Rincian pengeluaran bulan ini',
                  icon: Icons.pie_chart_outline_rounded,
                ),
                const SizedBox(height: 12),
                LaporanCostCard(costs: data.costDistribution),
                const SizedBox(height: 16),
                Text(
                  'Data laporan mengikuti transaksi yang tersimpan di perangkat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
