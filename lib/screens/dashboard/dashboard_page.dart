import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nyawit/data/dummy/dashboard_dummy.dart';
import 'package:nyawit/models/activity.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color secondaryGreen = Color(0xFF26964D);
  static const Color darkGreen = Color(0xFF0F4D29);
  static const Color lightGreen = Color(0xFFE8F4EC);
  static const Color background = Color(0xFFF5F7F5);
  static const Color textPrimary = Color(0xFF18211C);
  static const Color textSecondary = Color(0xFF7B827D);
  static const Color border = Color(0xFFE7EBE8);
  static const Color orange = Color(0xFFD58A00);
  static const Color lightOrange = Color(0xFFFFF2DA);
  static const Color blue = Color(0xFF3778C2);
  static const Color purple = Color(0xFF7356C7);
  static const Color teal = Color(0xFF168C79);

  @override
  Widget build(BuildContext context) {
    final data = dashboardOverview;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isSmall = width < 390;
            final bool isMobile = width < 600;
            final bool isTablet = width >= 600 && width < 1000;
            final bool isDesktop = width >= 1000;

            final double horizontalPadding = isSmall
                ? 14
                : isMobile
                ? 18
                : isTablet
                ? 26
                : 32;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    40,
                  ),
                  children: [
                    _DashboardHero(data: data, compact: isSmall),

                    const SizedBox(height: 22),

                    const _SectionHeader(
                      icon: Icons.bolt_rounded,
                      title: 'Akses cepat',
                      subtitle: 'Menu yang sering digunakan',
                    ),

                    const SizedBox(height: 12),

                    _QuickActions(compact: isSmall),

                    const SizedBox(height: 25),

                    const _SectionHeader(
                      icon: Icons.insights_rounded,
                      title: 'Performa bulan ini',
                      subtitle: 'Ringkasan produksi dan keuangan',
                    ),

                    const SizedBox(height: 12),

                    _ResponsiveKpiGrid(data: data, width: width),

                    const SizedBox(height: 18),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _HarvestProgressCard(data: data)),
                          const SizedBox(width: 14),
                          Expanded(child: _FinancialSummaryCard(data: data)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _HarvestProgressCard(data: data),
                          const SizedBox(height: 14),
                          _FinancialSummaryCard(data: data),
                        ],
                      ),

                    const SizedBox(height: 25),

                    const _SectionHeader(
                      icon: Icons.analytics_rounded,
                      title: 'Analitik',
                      subtitle: 'Pantau perkembangan produksi dan keuangan',
                    ),

                    const SizedBox(height: 12),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _ProductionChartCard(data: data)),
                          const SizedBox(width: 14),
                          Expanded(child: _IncomeCostChartCard(data: data)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _ProductionChartCard(data: data),
                          const SizedBox(height: 14),
                          _IncomeCostChartCard(data: data),
                        ],
                      ),

                    const SizedBox(height: 25),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _GardenPerformanceCard(data: data),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: _CostDistributionCard(data: data),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _GardenPerformanceCard(data: data),
                          const SizedBox(height: 14),
                          _CostDistributionCard(data: data),
                        ],
                      ),

                    const SizedBox(height: 25),

                    const _SectionHeader(
                      icon: Icons.history_rounded,
                      title: 'Aktivitas',
                      subtitle: 'Aktivitas terbaru dan agenda berikutnya',
                    ),

                    const SizedBox(height: 12),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ActivitySection(
                              title: 'Aktivitas terbaru',
                              icon: Icons.history_rounded,
                              activities: data.recentActivities
                                  .take(5)
                                  .toList(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _ActivitySection(
                              title: 'Kegiatan mendatang',
                              icon: Icons.event_available_rounded,
                              activities: data.upcomingActivities,
                              upcoming: true,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _ActivitySection(
                            title: 'Aktivitas terbaru',
                            icon: Icons.history_rounded,
                            activities: data.recentActivities.take(5).toList(),
                          ),
                          const SizedBox(height: 14),
                          _ActivitySection(
                            title: 'Kegiatan mendatang',
                            icon: Icons.event_available_rounded,
                            activities: data.upcomingActivities,
                            upcoming: true,
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(child: _LastHarvestCard(data: data)),
                          const SizedBox(width: 14),
                          Expanded(child: _PaymentSummaryCard(data: data)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _LastHarvestCard(data: data),
                          const SizedBox(height: 14),
                          _PaymentSummaryCard(data: data),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 18,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Ringkasan operasional kebun',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.primary,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HERO
// ============================================================================

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.data, required this.compact});

  final DashboardOverview data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF176B3A), Color(0xFF23874A)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: DashboardPage.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -65,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
          ),
          Positioned(
            right: 45,
            bottom: -85,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.035),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 45 : 51,
                    height: compact ? 45 : 51,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nyawit Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Ringkasan operasional kebun',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'AGUSTUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.075),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.agriculture_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Produksi bulan ini',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Target produksi sedang berjalan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

              const SizedBox(height: 16),

              Row(
                children: [
                  _HeroMiniStat(label: 'Kebun', value: data.totalGarden),
                  _HeroDivider(),
                  _HeroMiniStat(label: 'Blok', value: data.totalBlock),
                  _HeroDivider(),
                  _HeroMiniStat(label: 'Pekerja', value: data.totalWorker),
                  _HeroDivider(),
                  _HeroMiniStat(label: 'Truk', value: data.totalTruck),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.onSecondaryContainer, size: 19),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Panen', Icons.agriculture_rounded),
      ('Kebun', Icons.park_rounded),
      ('Pekerja', Icons.groups_rounded),
      ('Laporan', Icons.bar_chart_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width < 350) {
          columns = 2;
        } else if (width < 650) {
          columns = 4;
        } else {
          columns = 4;
        }

        final spacing = 9.0;
        final itemWidth = (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _QuickActionCard(title: item.$1, icon: item.$2),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.onSecondaryContainer, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// KPI
// ============================================================================

class _ResponsiveKpiGrid extends StatelessWidget {
  const _ResponsiveKpiGrid({required this.data, required this.width});

  final DashboardOverview data;
  final double width;

  @override
  Widget build(BuildContext context) {
    int columns;

    if (width < 370) {
      columns = 1;
    } else if (width < 1000) {
      columns = 2;
    } else {
      columns = 4;
    }

    final items = [
      _KpiData(
        label: 'Total panen',
        value: data.harvestThisMonth,
        trend: '+8,4%',
        trendLabel: 'vs bulan lalu',
        icon: Icons.scale_rounded,
        color: DashboardPage.secondaryGreen,
      ),
      _KpiData(
        label: 'Pendapatan',
        value: data.totalIncome,
        trend: '+12,6%',
        trendLabel: 'vs bulan lalu',
        icon: Icons.trending_up_rounded,
        color: DashboardPage.teal,
      ),
      _KpiData(
        label: 'Total biaya',
        value: data.totalCost,
        trend: '+4,2%',
        trendLabel: 'vs bulan lalu',
        icon: Icons.receipt_long_rounded,
        color: DashboardPage.orange,
      ),
      _KpiData(
        label: 'Laba bersih',
        value: data.netProfit,
        trend: '+17,8%',
        trendLabel: 'vs bulan lalu',
        icon: Icons.account_balance_wallet_rounded,
        color: DashboardPage.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        mainAxisExtent: width < 370
            ? 108
            : width < 1000
            ? 118
            : 126,
      ),
      itemBuilder: (context, index) {
        return _KpiCard(data: items[index]);
      },
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendLabel,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String trend;
  final String trendLabel;
  final IconData icon;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, color: data.color, size: 19),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 9,
                      color: data.color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      data.trend,
                      style: TextStyle(
                        color: data.color,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HARVEST PROGRESS
// ============================================================================

class _HarvestProgressCard extends StatelessWidget {
  const _HarvestProgressCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    final double progress = data.harvestProgress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DashboardPage.primaryGreen, DashboardPage.darkGreen],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DashboardPage.primaryGreen.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target panen',
                      style: TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Progress bulan ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: Text(
                  data.harvestThisMonth,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Target ${data.harvestTarget}',
                style: const TextStyle(color: Colors.white60, fontSize: 9),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white70,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    progress >= 0.8
                        ? 'Target bulan ini hampir tercapai.'
                        : 'Produksi masih berjalan menuju target.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      height: 1.3,
                    ),
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

// ============================================================================
// FINANCIAL SUMMARY
// ============================================================================

class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Ringkasan finansial',
            subtitle: 'Kondisi keuangan bulan ini',
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _FinancialMetric(
                  title: 'Pendapatan',
                  value: data.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: DashboardPage.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinancialMetric(
                  title: 'Biaya',
                  value: data.totalCost,
                  icon: Icons.arrow_upward_rounded,
                  color: DashboardPage.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: DashboardPage.lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: DashboardPage.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laba bersih',
                        style: TextStyle(
                          color: DashboardPage.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pendapatan setelah biaya',
                        style: TextStyle(
                          color: DashboardPage.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  data.netProfit,
                  style: const TextStyle(
                    color: DashboardPage.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

class _FinancialMetric extends StatelessWidget {
  const _FinancialMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHART CONTAINER
// ============================================================================

class _ChartContainer extends StatelessWidget {
  const _ChartContainer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: DashboardPage.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: DashboardPage.primaryGreen, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: DashboardPage.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardPage.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),

          const SizedBox(height: 13),

          child,
        ],
      ),
    );
  }
}

// ============================================================================
// PRODUCTION CHART
// ============================================================================

class _ProductionChartCard extends StatelessWidget {
  const _ProductionChartCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Produksi panen',
      subtitle: 'Perkembangan 7 periode terakhir',
      icon: Icons.show_chart_rounded,
      trailing: const _ChartBadge(text: 'KG'),
      child: SizedBox(
        width: double.infinity,
        height: 210,
        child: CustomPaint(
          painter: _ProductionChartPainter(values: data.productionTrend),
        ),
      ),
    );
  }
}

class _ChartBadge extends StatelessWidget {
  const _ChartBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: DashboardPage.lightGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: DashboardPage.primaryGreen,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCTION CHART PAINTER
// ============================================================================

class _ProductionChartPainter extends CustomPainter {
  _ProductionChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const left = 12.0;
    const right = 8.0;
    const top = 13.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;

    final chartHeight = size.height - top - bottom;

    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final maxValue = values.reduce(math.max);

    final minValue = values.reduce(math.min);

    final double range = maxValue - minValue == 0 ? 1.0 : maxValue - minValue;

    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDEA)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final double x = values.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * i / (values.length - 1);

      final double normalized = (values[i] - minValue) / range;

      final double y = top + chartHeight * (1 - normalized);

      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final areaPath = Path();

    areaPath.moveTo(points.first.dx, top + chartHeight);

    for (final point in points) {
      areaPath.lineTo(point.dx, point.dy);
    }

    areaPath.lineTo(points.last.dx, top + chartHeight);

    areaPath.close();

    final areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x33176B3A), Color(0x00176B3A)],
      ).createShader(Rect.fromLTWH(0, top, size.width, chartHeight));

    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = DashboardPage.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, linePaint);

    final outerPaint = Paint()..color = DashboardPage.primaryGreen;

    final innerPaint = Paint()..color = Colors.white;

    for (final point in points) {
      canvas.drawCircle(point, 4.5, outerPaint);

      canvas.drawCircle(point, 2, innerPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(
        text: 'P${i + 1}',
        style: const TextStyle(
          color: Color(0xFF8A918D),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProductionChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// ============================================================================
// INCOME VS COST CHART
// ============================================================================

class _IncomeCostChartCard extends StatelessWidget {
  const _IncomeCostChartCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Pendapatan vs biaya',
      subtitle: 'Perbandingan 7 periode terakhir',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendItem(
                label: 'Pendapatan',
                color: DashboardPage.primaryGreen,
              ),
              const SizedBox(width: 12),
              _LegendItem(label: 'Biaya', color: DashboardPage.orange),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            height: 190,
            child: CustomPaint(
              painter: _IncomeCostChartPainter(
                income: data.incomeTrend,
                cost: data.costTrend,
              ),
            ),
          ),
        ],
      ),
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
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: DashboardPage.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INCOME COST PAINTER
// ============================================================================

class _IncomeCostChartPainter extends CustomPainter {
  _IncomeCostChartPainter({required this.income, required this.cost});

  final List<double> income;
  final List<double> cost;

  @override
  void paint(Canvas canvas, Size size) {
    final count = math.min(income.length, cost.length);

    if (count == 0) return;

    const left = 8.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 28.0;

    final chartWidth = size.width - left - right;

    final chartHeight = size.height - top - bottom;

    final maxIncome = income.reduce(math.max);

    final maxCost = cost.reduce(math.max);

    final double maxValue = math.max(maxIncome, maxCost);

    if (maxValue <= 0) return;

    final groupWidth = chartWidth / count;

    final barWidth = math.min(14.0, groupWidth * 0.18);

    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDEA)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final incomePaint = Paint()..color = DashboardPage.primaryGreen;

    final costPaint = Paint()..color = DashboardPage.orange;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < count; i++) {
      final centerX = left + groupWidth * i + groupWidth / 2;

      final incomeHeight = income[i] / maxValue * chartHeight;

      final costHeight = cost[i] / maxValue * chartHeight;

      final incomeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - barWidth - 2,
          top + chartHeight - incomeHeight,
          barWidth,
          incomeHeight,
        ),
        const Radius.circular(5),
      );

      final costRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX + 2,
          top + chartHeight - costHeight,
          barWidth,
          costHeight,
        ),
        const Radius.circular(5),
      );

      canvas.drawRRect(incomeRect, incomePaint);

      canvas.drawRRect(costRect, costPaint);

      textPainter.text = TextSpan(
        text: 'P${i + 1}',
        style: const TextStyle(
          color: Color(0xFF8A918D),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _IncomeCostChartPainter oldDelegate) {
    return oldDelegate.income != income || oldDelegate.cost != cost;
  }
}

// ============================================================================
// GARDEN PERFORMANCE
// ============================================================================

class _GardenPerformanceCard extends StatelessWidget {
  const _GardenPerformanceCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.park_rounded,
            title: 'Performa kebun',
            subtitle: 'Pencapaian target produksi',
          ),

          const SizedBox(height: 18),

          ...data.gardenPerformance.map((garden) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _GardenProgress(garden: garden),
            );
          }),
        ],
      ),
    );
  }
}

class _GardenProgress extends StatelessWidget {
  const _GardenProgress({required this.garden});

  final GardenPerformance garden;

  @override
  Widget build(BuildContext context) {
    final double progress = garden.progress.clamp(0.0, 1.0).toDouble();

    final String status = progress >= 0.9
        ? 'Sangat baik'
        : progress >= 0.75
        ? 'Baik'
        : progress >= 0.5
        ? 'Berjalan'
        : 'Perlu perhatian';

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
                style: const TextStyle(
                  color: DashboardPage.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${garden.harvest.toStringAsFixed(0)} kg',
              style: const TextStyle(
                color: DashboardPage.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: DashboardPage.lightGreen,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: DashboardPage.primaryGreen,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color(0xFFF0F2F0),
            valueColor: const AlwaysStoppedAnimation(
              DashboardPage.primaryGreen,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Expanded(
              child: Text(
                status,
                style: const TextStyle(
                  color: DashboardPage.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Target ${garden.harvest.toStringAsFixed(0)} kg',
              style: const TextStyle(
                color: DashboardPage.textSecondary,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// COST DISTRIBUTION
// ============================================================================

class _CostDistributionCard extends StatelessWidget {
  const _CostDistributionCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    final double total = data.costDistribution.fold<double>(
      0.0,
      (sum, item) => sum + item.value,
    );

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.pie_chart_rounded,
            title: 'Distribusi biaya',
            subtitle: 'Komposisi pengeluaran kebun',
            trailing: Text(
              'Rp ${total.toStringAsFixed(2)} jt',
              style: const TextStyle(
                color: DashboardPage.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 18),

          ...data.costDistribution.map((item) {
            final double percentage = total == 0.0 ? 0.0 : item.value / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _CostItem(
                name: item.name,
                value: item.value,
                percentage: percentage,
                color: _costColor(item.name),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _costColor(String name) {
    switch (name) {
      case 'Panen':
        return DashboardPage.primaryGreen;
      case 'Perawatan':
        return DashboardPage.secondaryGreen;
      case 'Pupuk':
        return DashboardPage.orange;
      case 'Semprot':
        return DashboardPage.blue;
      default:
        return DashboardPage.textSecondary;
    }
  }
}

class _CostItem extends StatelessWidget {
  const _CostItem({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });

  final String name;
  final double value;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: DashboardPage.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Rp ${value.toStringAsFixed(2)} jt',
              style: const TextStyle(
                color: DashboardPage.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0).toDouble(),
            minHeight: 5,
            backgroundColor: const Color(0xFFF0F2F0),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTIVITY SECTION
// ============================================================================

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.icon,
    required this.activities,
    this.upcoming = false,
  });

  final String title;
  final IconData icon;
  final List<ActivityItem> activities;
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DashboardPage.lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: DashboardPage.primaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: DashboardPage.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      upcoming ? 'Agenda berikutnya' : 'Riwayat terbaru',
                      style: const TextStyle(
                        color: DashboardPage.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${activities.length}',
                  style: const TextStyle(
                    color: DashboardPage.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Belum ada aktivitas.',
                style: TextStyle(
                  color: DashboardPage.textSecondary,
                  fontSize: 10,
                ),
              ),
            )
          else
            ...activities.map((activity) {
              return _ActivityTile(activity: activity, upcoming: upcoming);
            }),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTIVITY TILE
// ============================================================================

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, this.upcoming = false});

  final ActivityItem activity;
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    final color = _activityColor(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEDF0ED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_activityIcon(activity.type), color: color, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.gardenName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage.textSecondary,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.date,
                  style: const TextStyle(color: Color(0xFF9AA09C), fontSize: 8),
                ),
              ],
            ),
          ),

          const SizedBox(width: 7),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount != '-')
                Text(
                  activity.amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),

              const SizedBox(height: 5),

              Container(
                constraints: const BoxConstraints(maxWidth: 78),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  activity.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.panen:
        return Icons.agriculture_rounded;

      case ActivityType.pupuk:
        return Icons.grass_rounded;

      case ActivityType.semprot:
        return Icons.water_drop_rounded;

      case ActivityType.tunas:
        return Icons.eco_rounded;

      case ActivityType.lainnya:
        return Icons.event_note_rounded;

      case ActivityType.semua:
        return Icons.apps_rounded;
    }
  }

  Color _activityColor(ActivityType type) {
    switch (type) {
      case ActivityType.panen:
        return DashboardPage.secondaryGreen;

      case ActivityType.pupuk:
        return DashboardPage.orange;

      case ActivityType.semprot:
        return DashboardPage.blue;

      case ActivityType.tunas:
        return DashboardPage.teal;

      case ActivityType.lainnya:
        return DashboardPage.textSecondary;

      case ActivityType.semua:
        return DashboardPage.primaryGreen;
    }
  }
}

// ============================================================================
// LAST HARVEST
// ============================================================================

class _LastHarvestCard extends StatelessWidget {
  const _LastHarvestCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: DashboardPage.lightGreen,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFDCEDE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: DashboardPage.primaryGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panen terakhir dikirim',
                  style: TextStyle(
                    color: DashboardPage.textSecondary,
                    fontSize: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pabrik Sawit Kaltim',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DashboardPage.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '12 Agustus • Pengiriman selesai',
                  style: TextStyle(
                    color: DashboardPage.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'TERKIRIM',
              style: TextStyle(
                color: DashboardPage.primaryGreen,
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAYMENT
// ============================================================================

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.data});

  final DashboardOverview data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: DashboardPage.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: DashboardPage.lightOrange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: DashboardPage.orange,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pembayaran tertunda',
                      style: TextStyle(
                        color: DashboardPage.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.unpaidCost,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardPage.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Perlu ditindaklanjuti',
                      style: TextStyle(
                        color: DashboardPage.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: DashboardPage.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: DashboardPage.primaryGreen,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD
// ============================================================================

class _CardContainer extends StatelessWidget {
  const _CardContainer({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// CARD HEADER
// ============================================================================

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.onSecondaryContainer, size: 19),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
              ),
            ],
          ),
        ),

        if (trailing != null) trailing!,
      ],
    );
  }
}
