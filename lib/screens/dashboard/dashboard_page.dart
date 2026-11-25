import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/dashboard_overview.dart';
import 'package:nyawit/models/activity.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/repositories/dashboard_repository.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/screens/lainnya/app_settings_page.dart';
import 'package:nyawit/screens/lainnya/backup_restore_page.dart';
import 'package:nyawit/screens/lainnya/master_data_page.dart';
import 'package:nyawit/screens/kebun/kebun_page.dart';
import 'package:nyawit/screens/lainnya/laporan_page.dart';
import 'package:nyawit/screens/panen/panen_page.dart';
import 'package:nyawit/screens/panen/panen_form_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_page.dart';
import 'package:nyawit/screens/lainnya/tarif_page.dart';
import 'package:sqflite/sqflite.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onNavigate});

  final ValueChanged<int>? onNavigate;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class DashboardPalette {
  const DashboardPalette._({
    required this.primary,
    required this.secondary,
    required this.heroStart,
    required this.heroEnd,
    required this.container,
    required this.containerText,
    required this.background,
    required this.surface,
    required this.text,
    required this.mutedText,
    required this.border,
    required this.orange,
    required this.orangeContainer,
    required this.blue,
    required this.purple,
    required this.teal,
    required this.chartGrid,
    required this.chartLabel,
  });

  factory DashboardPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    return DashboardPalette._(
      primary: scheme.primary,
      secondary: scheme.tertiary,
      heroStart: dark ? const Color(0xFF123B2D) : const Color(0xFF176B3A),
      heroEnd: dark ? const Color(0xFF205640) : const Color(0xFF23874A),
      container: scheme.secondaryContainer,
      containerText: scheme.onSecondaryContainer,
      background: scheme.surfaceContainerLow,
      surface: scheme.surface,
      text: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      border: scheme.outlineVariant,
      orange: dark ? const Color(0xFFFFC56E) : const Color(0xFF965900),
      orangeContainer: dark ? const Color(0xFF4A3518) : const Color(0xFFFFF0D8),
      blue: dark ? const Color(0xFF9BCBFF) : const Color(0xFF245D9C),
      purple: dark ? const Color(0xFFD0BCFF) : const Color(0xFF6547A5),
      teal: dark ? const Color(0xFF80D5C4) : const Color(0xFF08796A),
      chartGrid: scheme.outlineVariant.withValues(alpha: dark ? 0.42 : 0.55),
      chartLabel: scheme.onSurfaceVariant,
    );
  }

  final Color primary;
  final Color secondary;
  final Color heroStart;
  final Color heroEnd;
  final Color container;
  final Color containerText;
  final Color background;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color border;
  final Color orange;
  final Color orangeContainer;
  final Color blue;
  final Color purple;
  final Color teal;
  final Color chartGrid;
  final Color chartLabel;
}

class _QuickActionOption {
  const _QuickActionOption({
    required this.id,
    required this.title,
    required this.icon,
    this.kebunId,
  });

  final String id;
  final String title;
  final IconData icon;
  final int? kebunId;
}

class _DashboardPageState extends State<DashboardPage> {
  static const _quickActionsSettingKey = 'dashboard_quick_actions';
  static const _defaultQuickActionIds = ['reports', 'workers'];
  static const _quickActionOptions = <_QuickActionOption>[
    _QuickActionOption(
      id: 'reports',
      title: 'Laporan',
      icon: Icons.bar_chart_rounded,
    ),
    _QuickActionOption(
      id: 'workers',
      title: 'Pekerja',
      icon: Icons.groups_rounded,
    ),
    _QuickActionOption(
      id: 'panen',
      title: 'Panen',
      icon: Icons.agriculture_rounded,
    ),
    _QuickActionOption(id: 'kebun', title: 'Kebun', icon: Icons.park_rounded),
    _QuickActionOption(
      id: 'perawatan',
      title: 'Perawatan',
      icon: Icons.health_and_safety_rounded,
    ),
    _QuickActionOption(
      id: 'produk',
      title: 'Data Produk',
      icon: Icons.inventory_2_outlined,
    ),
    _QuickActionOption(
      id: 'truk',
      title: 'Data Truk',
      icon: Icons.local_shipping_outlined,
    ),
    _QuickActionOption(
      id: 'lokasi_timbang',
      title: 'Lokasi Timbang',
      icon: Icons.scale_outlined,
    ),
    _QuickActionOption(
      id: 'tarif',
      title: 'Tarif',
      icon: Icons.payments_outlined,
    ),
    _QuickActionOption(
      id: 'backup_restore',
      title: 'Backup & Restore',
      icon: Icons.backup_outlined,
    ),
    _QuickActionOption(
      id: 'settings',
      title: 'Pengaturan',
      icon: Icons.settings_outlined,
    ),
  ];

  late Future<DashboardOverview> _overview;
  List<String> _quickActionIds = _defaultQuickActionIds;
  List<Kebun> _quickActionGardens = [];

  List<_QuickActionOption> get _availableQuickActionOptions => [
    ..._quickActionOptions,
    for (final kebun in _quickActionGardens)
      if (kebun.id != null)
        _QuickActionOption(
          id: 'harvest_garden_${kebun.id}',
          title: 'Panen · ${kebun.nama}',
          icon: Icons.agriculture_rounded,
          kebunId: kebun.id,
        ),
  ];

  @override
  void initState() {
    super.initState();
    _overview = DashboardRepository().loadOverview();
    _loadQuickActions();
  }

  Future<void> _loadQuickActions() async {
    try {
      final gardens = await KebunRepository().getAll();
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'app_settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [_quickActionsSettingKey],
        limit: 1,
      );
      var selectedIds = _defaultQuickActionIds;
      if (rows.isNotEmpty) {
        final decoded = jsonDecode(rows.first['value']! as String);
        if (decoded is! List || decoded.any((value) => value is! String)) {
          throw const FormatException('Pengaturan akses cepat tidak valid.');
        }
        selectedIds = decoded.cast<String>();
      }

      final availableOptions = [
        ..._quickActionOptions,
        for (final kebun in gardens)
          if (kebun.id != null)
            _QuickActionOption(
              id: 'harvest_garden_${kebun.id}',
              title: 'Panen · ${kebun.nama}',
              icon: Icons.agriculture_rounded,
              kebunId: kebun.id,
            ),
      ];
      final availableIds = availableOptions.map((option) => option.id).toSet();
      final selectedSet = selectedIds.toSet().intersection(availableIds);
      if (!mounted) return;
      setState(() {
        _quickActionGardens = gardens;
        _quickActionIds = [
          for (final option in availableOptions)
            if (selectedSet.contains(option.id)) option.id,
        ];
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaturan akses cepat gagal dimuat: $error')),
      );
    }
  }

  Future<void> _refresh() async {
    final overview = DashboardRepository().loadOverview();
    if (!mounted) return;
    setState(() => _overview = overview);
    await Future.wait([overview, _loadQuickActions()]);
  }

  Future<void> _editQuickActions() async {
    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final selection = _quickActionIds.toSet();
        final gardenActions = _availableQuickActionOptions
            .where((option) => option.kebunId != null)
            .toList();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Tambah atau edit akses cepat'),
            content: SizedBox(
              width: 360,
              height: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in _quickActionOptions)
                      CheckboxListTile(
                        value: selection.contains(option.id),
                        secondary: Icon(option.icon),
                        title: Text(option.title),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (selected) {
                          setDialogState(() {
                            if (selected == true) {
                              selection.add(option.id);
                            } else {
                              selection.remove(option.id);
                            }
                          });
                        },
                      ),
                    if (gardenActions.isNotEmpty) ...[
                      const Divider(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Akses cepat per kebun',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                      for (final option in gardenActions)
                        CheckboxListTile(
                          value: selection.contains(option.id),
                          secondary: Icon(option.icon),
                          title: Text(option.title),
                          subtitle: const Text(
                            'Buka form panen dengan kebun terpilih',
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (selected) {
                            setDialogState(() {
                              if (selected == true) {
                                selection.add(option.id);
                              } else {
                                selection.remove(option.id);
                              }
                            });
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  _availableQuickActionOptions
                      .where((option) => selection.contains(option.id))
                      .map((option) => option.id)
                      .toList(),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
    if (selectedIds == null) return;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('app_settings', {
        'key': _quickActionsSettingKey,
        'value': jsonEncode(selectedIds),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      if (!mounted) return;
      setState(() => _quickActionIds = selectedIds);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akses cepat gagal disimpan: $error')),
      );
    }
  }

  Future<void> _openQuickAction(String id) async {
    final gardenAction = _availableQuickActionOptions
        .where((option) => option.id == id && option.kebunId != null)
        .firstOrNull;
    if (gardenAction != null) {
      await _openPage(
        PanenFormPage(initialKebunId: gardenAction.kebunId, lockKebun: true),
      );
      return;
    }

    switch (id) {
      case 'reports':
        await _openPage(const LaporanPage());
        return;
      case 'workers':
        await _openPage(const PekerjaPage());
        return;
      case 'panen':
        _openTab(2, const PanenPage());
        return;
      case 'kebun':
        _openTab(1, const KebunPage());
        return;
      case 'perawatan':
        _openTab(3, const PerawatanPage());
        return;
      case 'produk':
        await _openPage(const ProdukPage());
        return;
      case 'truk':
        await _openPage(const TrukPage());
        return;
      case 'lokasi_timbang':
        await _openPage(const LokasiTimbangPage());
        return;
      case 'tarif':
        await _openPage(const TarifPage());
        return;
      case 'backup_restore':
        await _openPage(const BackupRestorePage());
        return;
      case 'settings':
        await _openPage(const AppSettingsPage());
        return;
    }
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) await _refresh();
  }

  void _openTab(int index, Widget fallbackPage) {
    final onNavigate = widget.onNavigate;
    if (onNavigate != null) {
      onNavigate(index);
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => fallbackPage));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardOverview>(
      future: _overview,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ringkasan dashboard gagal dimuat.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        _refresh();
                      },
                      icon: Icon(Icons.refresh_rounded),
                      label: Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildDashboard(context, snapshot.data!);
      },
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardOverview data) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
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
                child: RefreshIndicator(
                  onRefresh: _refresh,
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

                      _SectionHeader(
                        icon: Icons.bolt_rounded,
                        title: 'Akses cepat',
                        subtitle: 'Menu yang sering digunakan',
                        trailing: IconButton(
                          tooltip: 'Tambah atau edit akses cepat',
                          onPressed: _editQuickActions,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _QuickActions(
                        actions: [
                          for (final option in _availableQuickActionOptions)
                            if (_quickActionIds.contains(option.id))
                              (
                                title: option.title,
                                icon: option.icon,
                                onTap: () async {
                                  await _openQuickAction(option.id);
                                },
                              ),
                        ],
                      ),

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

                      _SectionHeader(
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
                              activities: data.recentActivities
                                  .take(5)
                                  .toList(),
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
              ),
            );
          },
        ),
      ),
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
    final palette = DashboardPalette.of(context);
    return Container(
      padding: EdgeInsets.all(compact ? 17 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroStart, palette.heroEnd],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: DashboardPalette.of(context).primary.withValues(alpha: 0.18),
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
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.monthLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
                    Icon(
                      Icons.agriculture_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
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
                            data.harvestThisMonth,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
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
                  _HeroMiniStat(label: 'Pohon', value: data.totalTrees),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
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
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<({String title, IconData icon, VoidCallback onTap})> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Text(
        'Belum ada akses cepat. Ketuk + untuk menambahkan.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final availableColumns = width < 350
            ? 2
            : width < 650
            ? 3
            : 5;
        final columns = math.min(actions.length, availableColumns);
        final spacing = 9.0;
        final itemWidth = (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: item.title,
                icon: item.icon,
                onTap: item.onTap,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
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
        trend: 'BULAN INI',
        icon: Icons.scale_rounded,
        color: DashboardPalette.of(context).secondary,
      ),
      _KpiData(
        label: 'Pendapatan',
        value: data.totalIncome,
        trend: 'BULAN INI',
        icon: Icons.trending_up_rounded,
        color: DashboardPalette.of(context).teal,
      ),
      _KpiData(
        label: 'Total biaya',
        value: data.totalCost,
        trend: 'BULAN INI',
        icon: Icons.receipt_long_rounded,
        color: DashboardPalette.of(context).orange,
      ),
      _KpiData(
        label: 'Laba bersih',
        value: data.netProfit,
        trend: 'BULAN INI',
        icon: Icons.account_balance_wallet_rounded,
        color: DashboardPalette.of(context).purple,
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
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String trend;
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
                child: Text(
                  data.trend,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
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
    final palette = DashboardPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroStart, palette.heroEnd],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DashboardPalette.of(context).primary.withValues(alpha: 0.13),
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
              Icon(Icons.agriculture_rounded, color: palette.surface, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Produksi bulan ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                data.harvestThisMonth,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _HarvestMiniMetric(
                  label: 'Rata-rata per panen',
                  value: data.averageHarvest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HarvestMiniMetric(
                  label: 'Transaksi',
                  value: data.totalHarvestTransaction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HarvestMiniMetric extends StatelessWidget {
  const _HarvestMiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 9)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

          Text(
            'Panen ${data.harvestCostSummary}  •  Perawatan ${data.careCostSummary}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _FinancialMetric(
                  title: 'Pendapatan',
                  value: data.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: DashboardPalette.of(context).teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinancialMetric(
                  title: 'Biaya',
                  value: data.totalCost,
                  icon: Icons.arrow_upward_rounded,
                  color: DashboardPalette.of(context).orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: DashboardPalette.of(context).container,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: DashboardPalette.of(context).surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: DashboardPalette.of(context).containerText,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laba bersih',
                        style: TextStyle(
                          color: DashboardPalette.of(context).mutedText,
                          fontSize: 9,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pendapatan setelah biaya',
                        style: TextStyle(
                          color: DashboardPalette.of(context).text,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  data.netProfit,
                  style: TextStyle(
                    color: DashboardPalette.of(context).containerText,
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
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
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
                  color: DashboardPalette.of(context).container,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: DashboardPalette.of(context).containerText,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: DashboardPalette.of(context).text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DashboardPalette.of(context).mutedText,
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
      subtitle: 'Perkembangan 7 bulan terakhir',
      icon: Icons.show_chart_rounded,
      trailing: const _ChartBadge(text: 'KG'),
      child: SizedBox(
        width: double.infinity,
        height: 210,
        child: CustomPaint(
          painter: _ProductionChartPainter(
            values: data.productionTrend,
            labels: data.monthLabels,
            palette: DashboardPalette.of(context),
          ),
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
        color: DashboardPalette.of(context).container,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: DashboardPalette.of(context).containerText,
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
  _ProductionChartPainter({
    required this.values,
    required this.labels,
    required this.palette,
  });

  final List<double> values;
  final List<String> labels;
  final DashboardPalette palette;

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
      ..color = palette.chartGrid
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
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.primary.withValues(alpha: 0.20),
          palette.primary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, top, size.width, chartHeight));

    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = palette.primary
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

    final outerPaint = Paint()..color = palette.primary;

    final innerPaint = Paint()..color = palette.surface;

    for (final point in points) {
      canvas.drawCircle(point, 4.5, outerPaint);

      canvas.drawCircle(point, 2, innerPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(
        text: i < labels.length ? labels[i] : '',
        style: TextStyle(
          color: palette.chartLabel,
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
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.palette.primary != palette.primary ||
        oldDelegate.palette.chartGrid != palette.chartGrid ||
        oldDelegate.palette.chartLabel != palette.chartLabel;
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
      subtitle: 'Perbandingan bulanan 7 bulan terakhir (Rp juta)',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendItem(
                label: 'Pendapatan',
                color: DashboardPalette.of(context).containerText,
              ),
              const SizedBox(width: 12),
              _LegendItem(
                label: 'Biaya',
                color: DashboardPalette.of(context).orange,
              ),
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
                labels: data.monthLabels,
                palette: DashboardPalette.of(context),
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
          style: TextStyle(
            color: DashboardPalette.of(context).mutedText,
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
  _IncomeCostChartPainter({
    required this.income,
    required this.cost,
    required this.labels,
    required this.palette,
  });

  final List<double> income;
  final List<double> cost;
  final List<String> labels;
  final DashboardPalette palette;

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
      ..color = palette.chartGrid
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final incomePaint = Paint()..color = palette.primary;

    final costPaint = Paint()..color = palette.orange;

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
        text: i < labels.length ? labels[i] : '',
        style: TextStyle(
          color: palette.chartLabel,
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
    return oldDelegate.income != income ||
        oldDelegate.cost != cost ||
        oldDelegate.labels != labels ||
        oldDelegate.palette.primary != palette.primary ||
        oldDelegate.palette.orange != palette.orange ||
        oldDelegate.palette.chartGrid != palette.chartGrid ||
        oldDelegate.palette.chartLabel != palette.chartLabel;
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
            subtitle: 'Kontribusi produksi bulan ini',
          ),

          const SizedBox(height: 18),

          if (data.gardenPerformance.isEmpty)
            Text(
              'Belum ada data panen bulan ini.',
              style: TextStyle(
                color: DashboardPalette.of(context).mutedText,
                fontSize: 10,
              ),
            )
          else
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
    final double progress = garden.contribution.clamp(0.0, 1.0).toDouble();

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
                  color: DashboardPalette.of(context).text,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${garden.harvest.toStringAsFixed(0)} kg',
              style: TextStyle(
                color: DashboardPalette.of(context).text,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: DashboardPalette.of(context).container,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: DashboardPalette.of(context).containerText,
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
            backgroundColor: DashboardPalette.of(
              context,
            ).border.withValues(alpha: 0.35),
            valueColor: AlwaysStoppedAnimation(
              DashboardPalette.of(context).primary,
            ),
          ),
        ),

        const SizedBox(height: 5),
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
              style: TextStyle(
                color: DashboardPalette.of(context).text,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (data.costDistribution.isEmpty)
            Text(
              'Belum ada biaya tercatat bulan ini.',
              style: TextStyle(
                color: DashboardPalette.of(context).mutedText,
                fontSize: 10,
              ),
            )
          else
            ...data.costDistribution.map((item) {
              final double percentage = item.value / total;

              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _CostItem(
                  name: item.name,
                  value: item.value,
                  percentage: percentage,
                  color: _costColor(item.name, DashboardPalette.of(context)),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _costColor(String name, DashboardPalette palette) {
    switch (name) {
      case 'Panen':
        return palette.primary;
      case 'Pupuk':
        return palette.secondary;
      case 'Tunas':
        return palette.orange;
      case 'Semprot':
        return palette.blue;
      case 'Lainnya':
        return palette.purple;
      default:
        return palette.mutedText;
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
                style: TextStyle(
                  color: DashboardPalette.of(context).text,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Rp ${value.toStringAsFixed(2)} jt',
              style: TextStyle(
                color: DashboardPalette.of(context).text,
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
            backgroundColor: DashboardPalette.of(
              context,
            ).border.withValues(alpha: 0.35),
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
                  color: DashboardPalette.of(context).container,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: DashboardPalette.of(context).primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: DashboardPalette.of(context).text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      upcoming ? 'Agenda berikutnya' : 'Riwayat terbaru',
                      style: TextStyle(
                        color: DashboardPalette.of(context).mutedText,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardPalette.of(context).background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${activities.length}',
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (activities.isEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Belum ada aktivitas.',
                style: TextStyle(
                  color: DashboardPalette.of(context).mutedText,
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
    final color = _activityColor(activity.type, DashboardPalette.of(context));

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DashboardPalette.of(context).border),
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
                  style: TextStyle(
                    color: DashboardPalette.of(context).text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.gardenName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.date,
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
                    fontSize: 8,
                  ),
                ),
                if (activity.cost != '-')
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '${activity.cost} • ${activity.paymentStatus}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DashboardPalette.of(context).mutedText,
                        fontSize: 8,
                      ),
                    ),
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
                  style: TextStyle(
                    color: DashboardPalette.of(context).text,
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

  Color _activityColor(ActivityType type, DashboardPalette palette) {
    switch (type) {
      case ActivityType.panen:
        return palette.secondary;

      case ActivityType.pupuk:
        return palette.orange;

      case ActivityType.semprot:
        return palette.blue;

      case ActivityType.tunas:
        return palette.teal;

      case ActivityType.lainnya:
        return palette.mutedText;

      case ActivityType.semua:
        return palette.primary;
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
        color: DashboardPalette.of(context).container,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: DashboardPalette.of(context).border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DashboardPalette.of(context).surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: DashboardPalette.of(context).primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panen terakhir tercatat',
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
                    fontSize: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  data.lastHarvestGarden ?? 'Belum ada data panen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DashboardPalette.of(context).containerText,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  data.lastHarvestDate == null
                      ? 'Catat panen untuk melihat ringkasan di sini.'
                      : '${data.lastHarvestDate} • ${data.lastHarvestMethod}',
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
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
              color: DashboardPalette.of(context).surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.lastHarvestAmount ?? '—',
              style: TextStyle(
                color: DashboardPalette.of(context).primary,
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: DashboardPalette.of(context).orangeContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.pending_actions_rounded,
              color: DashboardPalette.of(context).orange,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran tertunda',
                  style: TextStyle(
                    color: DashboardPalette.of(context).text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.unpaidCost,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DashboardPalette.of(context).orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.hasUnpaidCost
                      ? 'Perlu ditindaklanjuti'
                      : 'Tidak ada tagihan tertunda',
                  style: TextStyle(
                    color: DashboardPalette.of(context).mutedText,
                    fontSize: 8,
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
