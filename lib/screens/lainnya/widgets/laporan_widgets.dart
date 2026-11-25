import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyawit/models/dashboard_overview.dart';

const _tabular = [FontFeature.tabularFigures()];

class LaporanHeroCard extends StatelessWidget {
  const LaporanHeroCard({super.key, required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [
                  colors.primary,
                  Color.lerp(colors.primary, colors.tertiary, .4)!,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: .22)
              : colors.primary.withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Color(0xFF86EFAC),
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analisis usaha kebun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Periode laporan: $monthLabel',
                  style: const TextStyle(
                    color: Color(0xFFD4E3D8),
                    fontSize: 12,
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

class LaporanSectionHeader extends StatelessWidget {
  const LaporanSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: colors.onPrimaryContainer),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LaporanSummaryGrid extends StatelessWidget {
  const LaporanSummaryGrid({super.key, required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryData(
        label: 'Produksi',
        value: data.harvestThisMonth,
        icon: Icons.agriculture_rounded,
      ),
      _SummaryData(
        label: 'Pendapatan',
        value: data.totalIncome,
        icon: Icons.trending_up_rounded,
      ),
      _SummaryData(
        label: 'Total biaya',
        value: data.totalCost,
        icon: Icons.payments_outlined,
      ),
      _SummaryData(
        label: 'Laba bersih',
        value: data.netProfit,
        icon: Icons.account_balance_wallet_outlined,
      ),
      _SummaryData(
        label: 'Transaksi panen',
        value: data.totalHarvestTransaction,
        icon: Icons.receipt_long_outlined,
      ),
      _SummaryData(
        label: 'Rata-rata panen',
        value: data.averageHarvest,
        icon: Icons.scale_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 2;
        final spacing = 10.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                height: 100,
                child: _SummaryCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryData item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, size: 18, color: colors.primary),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFeatures: _tabular,
            ),
          ),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LaporanTrendCard extends StatelessWidget {
  const LaporanTrendCard({super.key, required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChartLegend(),
          const SizedBox(height: 18),
          SizedBox(
            height: 152,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.monthLabels.length, (index) {
                final production = _safeValue(data.productionTrend, index);
                final income = _safeValue(data.incomeTrend, index);
                final cost = _safeValue(data.costTrend, index);
                return Expanded(
                  child: _MonthlyBars(
                    label: data.monthLabels[index],
                    production: production,
                    income: income,
                    cost: cost,
                    maxProduction: _maxValue(data.productionTrend),
                    maxMoney: _maxValue([
                      ...data.incomeTrend,
                      ...data.costTrend,
                    ]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nilai pendapatan dan biaya pada grafik dalam juta rupiah.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  static double _safeValue(List<double> values, int index) =>
      index < values.length ? values[index] : 0;

  static double _maxValue(List<double> values) =>
      values.fold<double>(0, (max, value) => value > max ? value : max);
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(label: 'Produksi kg', color: colors.primary),
        _LegendItem(label: 'Pendapatan jt', color: colors.tertiary),
        _LegendItem(label: 'Biaya jt', color: colors.error),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({
    required this.label,
    required this.production,
    required this.income,
    required this.cost,
    required this.maxProduction,
    required this.maxMoney,
  });

  final String label;
  final double production;
  final double income;
  final double cost;
  final double maxProduction;
  final double maxMoney;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const graphHeight = 111.0;
    final productionHeight = maxProduction == 0
        ? 0.0
        : (production / maxProduction * graphHeight)
              .clamp(2.0, graphHeight)
              .toDouble();
    final incomeHeight = maxMoney == 0
        ? 0.0
        : (income / maxMoney * graphHeight).clamp(2.0, graphHeight).toDouble();
    final costHeight = maxMoney == 0
        ? 0.0
        : (cost / maxMoney * graphHeight).clamp(2.0, graphHeight).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: graphHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Bar(height: productionHeight, color: colors.primary),
                const SizedBox(width: 2),
                _Bar(height: incomeHeight, color: colors.tertiary),
                const SizedBox(width: 2),
                _Bar(height: costHeight, color: colors.error),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (height == 0) return const SizedBox(width: 5);
    return Container(
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class LaporanGardenCard extends StatelessWidget {
  const LaporanGardenCard({super.key, required this.gardens});

  final List<GardenPerformance> gardens;

  @override
  Widget build(BuildContext context) {
    if (gardens.isEmpty) {
      return const _EmptyReportCard(message: 'Belum ada data panen bulan ini.');
    }

    final maxHarvest = gardens.fold<double>(
      0,
      (max, garden) => garden.harvest > max ? garden.harvest : max,
    );

    return _ReportCard(
      child: Column(
        children: gardens
            .map(
              (garden) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _GardenReportRow(garden: garden, maxHarvest: maxHarvest),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GardenReportRow extends StatelessWidget {
  const _GardenReportRow({required this.garden, required this.maxHarvest});

  final GardenPerformance garden;
  final double maxHarvest;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = maxHarvest == 0
        ? 0.0
        : (garden.harvest / maxHarvest).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                garden.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${NumberFormat('#,##0', 'id_ID').format(garden.harvest)} kg',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFeatures: _tabular,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              '${(garden.contribution * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                fontFeatures: _tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: colors.outlineVariant.withValues(alpha: .32),
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      ],
    );
  }
}

class LaporanCostCard extends StatelessWidget {
  const LaporanCostCard({super.key, required this.costs});

  final List<CostDistribution> costs;

  @override
  Widget build(BuildContext context) {
    if (costs.isEmpty) {
      return const _EmptyReportCard(
        message: 'Belum ada biaya tercatat bulan ini.',
      );
    }

    final total = costs.fold<double>(0, (sum, cost) => sum + cost.value);
    final colors = Theme.of(context).colorScheme;

    return _ReportCard(
      child: Column(
        children: costs.map((cost) {
          final share = total == 0 ? 0.0 : cost.value / total;
          final amount = cost.value * 1000000;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cost.name,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${(share * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                              fontFeatures: _tabular,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 6,
                          backgroundColor: colors.outlineVariant.withValues(
                            alpha: .32,
                          ),
                          valueColor: AlwaysStoppedAnimation(
                            _costColor(cost.name, colors),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 105,
                  child: Text(
                    _currency(amount),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _costColor(String name, ColorScheme colors) => switch (name) {
    'Panen' => colors.primary,
    'Pupuk' => colors.tertiary,
    'Tunas' => const Color(0xFFE6A23C),
    'Semprot' => const Color(0xFF4C9BD6),
    'Lainnya' => const Color(0xFF9874D4),
    _ => colors.onSurfaceVariant,
  };
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: child,
    );
  }
}

String _currency(num value) =>
    'Rp ${NumberFormat('#,##0', 'id_ID').format(value.round())}';
