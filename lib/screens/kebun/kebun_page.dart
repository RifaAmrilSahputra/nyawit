import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/screens/kebun/kebun_detail_page.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_search.dart';
import 'package:nyawit/screens/panen/panen_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_page.dart';

class KebunPage extends StatefulWidget {
  const KebunPage({super.key});

  @override
  State<KebunPage> createState() => _KebunPageState();
}

class _KebunPageState extends State<KebunPage> {
  final KebunRepository _repository = KebunRepository();

  late Future<List<Kebun>> _kebunFuture;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadKebun();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadKebun() {
    _kebunFuture = _repository.getAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFormAndRefresh() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const KebunFormPage()));

    if (result == true && mounted) {
      setState(() {
        _loadKebun();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loadKebun();
    });

    await _kebunFuture;
  }

  List<Kebun> _filterKebun(List<Kebun> kebuns) {
    if (_searchQuery.isEmpty) {
      return kebuns;
    }

    return kebuns.where((kebun) {
      final nama = kebun.nama.toLowerCase();
      final lokasi = kebun.lokasi?.toLowerCase() ?? '';

      return nama.contains(_searchQuery) || lokasi.contains(_searchQuery);
    }).toList();
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
        toolbarHeight: 18,
      ),

      body: FutureBuilder<List<Kebun>>(
        future: _kebunFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(
              onRetry: () {
                setState(() {
                  _loadKebun();
                });
              },
            );
          }

          final allKebuns = snapshot.data ?? <Kebun>[];

          final kebuns = _filterKebun(allKebuns);

          if (allKebuns.isEmpty) {
            return _EmptyView(onAdd: _openFormAndRefresh);
          }

          return RefreshIndicator(
            color: const Color(0xFF176B3A),
            onRefresh: _refresh,

            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),

              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),

              children: [
                _buildHeader(allKebuns, colors),

                const SizedBox(height: 20),

                KebunSearchField(
                  controller: _searchController,
                  query: _searchQuery,
                ),

                const SizedBox(height: 24),

                if (kebuns.isEmpty)
                  const _NoSearchResult()
                else
                  ...kebuns.map(
                    (kebun) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),

                      child: GardenCard(
                        kebun: kebun,

                        onChanged: () {
                          setState(() {
                            _loadKebun();
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(List<Kebun> kebuns, ColorScheme colors) {
    double totalLuas = 0;
    int totalPohon = 0;

    for (final kebun in kebuns) {
      totalLuas += kebun.luas ?? 0;
      totalPohon += kebun.jumlahPohon ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF176B3A),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF176B3A).withValues(alpha: 0.16),

            blurRadius: 22,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,

            child: Container(
              width: 150,
              height: 150,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
          ),

          Positioned(
            right: -20,
            bottom: -70,

            child: Container(
              width: 130,
              height: 130,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withValues(alpha: 0.035),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 330;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 48,
                        height: 48,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.forest_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Perkebunan',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 3),

                            const Text(
                              'Kelola dan pantau kebun Anda',

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      _AddGardenButton(
                        onPressed: _openFormAndRefresh,
                        compact: isCompact,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.075),

                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.landscape_rounded,
                        value: '${kebuns.length}',
                        label: 'Kebun',
                      ),
                    ),

                    _SummaryDivider(),

                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.straighten_rounded,
                        value: _formatNumber(totalLuas),
                        label: 'Total Ha',
                      ),
                    ),

                    _SummaryDivider(),

                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.forest_rounded,
                        value: _formatNumber(totalPohon),
                        label: 'Pohon',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(num value) {
    final number = value.toDouble();

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}

// =============================================================
// ADD GARDEN BUTTON
// =============================================================

class _AddGardenButton extends StatelessWidget {
  const _AddGardenButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: onPressed,

        tooltip: 'Tambah Kebun',

        style: IconButton.styleFrom(
          backgroundColor: Colors.white,

          foregroundColor: const Color(0xFF176B3A),

          minimumSize: const Size(42, 42),

          fixedSize: const Size(42, 42),

          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),

        icon: const Icon(Icons.add_rounded, size: 22),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,

      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,

        foregroundColor: const Color(0xFF176B3A),

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        minimumSize: const Size(0, 42),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),

      icon: const Icon(Icons.add_rounded, size: 18),

      label: const Text(
        'Tambah',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// =============================================================
// GARDEN CARD
// =============================================================

class GardenCard extends StatelessWidget {
  const GardenCard({super.key, required this.kebun, required this.onChanged});

  final Kebun kebun;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasDescription = kebun.keterangan?.isNotEmpty ?? false;

    final status = hasDescription ? 'Aktif' : 'Siap';

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => KebunDetailPage(kebun: kebun)),
          );

          if (changed == true) {
            onChanged();
          }
        },

        borderRadius: BorderRadius.circular(22),

        child: Ink(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),

                blurRadius: 16,

                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 50,
                    height: 50,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F3E9),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: const Icon(
                      Icons.forest_rounded,
                      color: Color(0xFF176B3A),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          kebun.nama,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Color(0xFF7B827D),
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                kebun.lokasi ?? 'Lokasi belum diisi',

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7B827D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 7,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F6),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: _GardenStat(
                        icon: Icons.landscape_rounded,
                        label: 'Luas',
                        value: kebun.luas == null ? '-' : '${kebun.luas} Ha',
                      ),
                    ),

                    const _VerticalDivider(),

                    Expanded(
                      child: _GardenStat(
                        icon: Icons.forest_rounded,
                        label: 'Pohon',
                        value: kebun.jumlahPohon == null
                            ? '-'
                            : _formatNumber(kebun.jumlahPohon!),
                      ),
                    ),

                    const _VerticalDivider(),

                    Expanded(
                      child: _GardenStat(
                        icon: Icons.info_outline_rounded,
                        label: 'Data',
                        value: hasDescription ? 'Lengkap' : 'Dasar',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =====================================================
              // RESPONSIVE ACTIONS
              // =====================================================
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  // -------------------------------------------------
                  // VERY SMALL SCREEN
                  // -------------------------------------------------

                  if (width < 350) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _HarvestButton(kebun: kebun)),

                            const SizedBox(width: 8),

                            Expanded(child: _MaintenanceButton(kebun: kebun)),
                          ],
                        ),

                        const SizedBox(height: 7),

                        _DetailButton(
                          kebun: kebun,

                          colors: colors,

                          onChanged: onChanged,

                          fullWidth: true,
                        ),
                      ],
                    );
                  }

                  // -------------------------------------------------
                  // NORMAL SCREEN
                  // -------------------------------------------------

                  return Row(
                    children: [
                      Expanded(flex: 3, child: _HarvestButton(kebun: kebun)),

                      const SizedBox(width: 7),

                      Expanded(
                        flex: 4,

                        child: _MaintenanceButton(kebun: kebun),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        flex: 3,

                        child: _DetailButton(
                          kebun: kebun,

                          colors: colors,

                          onChanged: onChanged,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(num value) {
    final number = value.toDouble();

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}

// =============================================================
// HARVEST BUTTON
// =============================================================

class _HarvestButton extends StatelessWidget {
  const _HarvestButton({required this.kebun});

  final Kebun kebun;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => PanenPage(kebunId: kebun.id, kebunName: kebun.nama),
          ),
        );
      },

      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF176B3A),

        side: const BorderSide(color: Color(0xFF176B3A)),

        minimumSize: const Size(0, 42),

        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      icon: const Icon(Icons.grass_rounded, size: 17),

      label: const Flexible(
        child: Text(
          'Panen',

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// =============================================================
// MAINTENANCE BUTTON
// =============================================================

class _MaintenanceButton extends StatelessWidget {
  const _MaintenanceButton({required this.kebun});

  final Kebun kebun;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                PerawatanPage(kebunId: kebun.id, kebunName: kebun.nama),
          ),
        );
      },

      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF176B3A),

        side: const BorderSide(color: Color(0xFF176B3A)),

        minimumSize: const Size(0, 42),

        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      icon: const Icon(Icons.bloodtype_rounded, size: 17),

      label: const Flexible(
        child: Text(
          'Perawatan',

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// =============================================================
// DETAIL BUTTON
// =============================================================

class _DetailButton extends StatelessWidget {
  const _DetailButton({
    required this.kebun,
    required this.colors,
    required this.onChanged,
    this.fullWidth = false,
  });

  final Kebun kebun;
  final ColorScheme colors;
  final VoidCallback onChanged;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = TextButton.icon(
      onPressed: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => KebunDetailPage(kebun: kebun)),
        );

        if (changed == true) {
          onChanged();
        }
      },

      style: TextButton.styleFrom(
        foregroundColor: colors.primary,

        minimumSize: const Size(0, 42),

        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      icon: const Icon(Icons.arrow_forward_rounded, size: 17),

      label: Flexible(
        child: Text(
          fullWidth ? 'Lihat detail kebun' : 'Detail',

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

// =============================================================
// SUMMARY ITEM
// =============================================================

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),

        const SizedBox(height: 5),

        Text(
          value,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

// =============================================================
// SUMMARY DIVIDER
// =============================================================

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 1,

      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

// =============================================================
// GARDEN STAT
// =============================================================

class _GardenStat extends StatelessWidget {
  const _GardenStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF176B3A)),

        const SizedBox(height: 5),

        Text(
          value,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(fontSize: 10, color: Color(0xFF7B827D)),
        ),
      ],
    );
  }
}

// =============================================================
// VERTICAL DIVIDER
// =============================================================

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: const Color(0xFFE0E5E1));
  }
}

// =============================================================
// STATUS BADGE
// =============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE5F5EA) : const Color(0xFFFFF3DD),

        borderRadius: BorderRadius.circular(999),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 6,
            height: 6,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: isActive
                  ? const Color(0xFF26964D)
                  : const Color(0xFFD58A00),
            ),
          ),

          const SizedBox(width: 5),

          Text(
            status,

            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,

              color: isActive
                  ? const Color(0xFF227E43)
                  : const Color(0xFFAA6D00),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// EMPTY VIEW
// =============================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: const BoxDecoration(
                color: Color(0xFFE4F3E9),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.forest_rounded,
                size: 45,
                color: Color(0xFF176B3A),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Belum ada kebun',

              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 7),

            const Text(
              'Tambahkan kebun pertama untuk mulai '
              'mengelola data perkebunan.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF777D79),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onAdd,

              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF176B3A),

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              icon: const Icon(Icons.add_rounded),

              label: const Text(
                'Tambah Kebun',

                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// NO SEARCH RESULT
// =============================================================

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),

      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          const Text(
            'Kebun tidak ditemukan',

            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 5),

          Text(
            'Coba gunakan nama atau lokasi lain.',

            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// LOADING VIEW
// =============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF176B3A)),
    );
  }
}

// =============================================================
// ERROR VIEW
// =============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Gagal memuat data',

              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              'Terjadi masalah saat mengambil data kebun.',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// DETAIL PAGE
// =============================================================

class KebunDetailPageLegacy extends StatelessWidget {
  const KebunDetailPageLegacy({super.key, required this.kebun});

  final Kebun kebun;

  Future<void> _editKebun(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => KebunFormPage(kebun: kebun)),
    );

    if (changed == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final status = (kebun.keterangan?.isNotEmpty ?? false) ? 'Aktif' : 'Siap';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),

        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Detail Kebun',

          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: IconButton(
              onPressed: () => _editKebun(context),

              style: IconButton.styleFrom(backgroundColor: Colors.white),

              icon: const Icon(Icons.edit_rounded, size: 20),
            ),
          ),
        ],
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),

        children: [
          _buildDetailHeader(colors, status),

          const SizedBox(height: 22),

          _DetailSection(
            icon: Icons.info_outline_rounded,

            title: 'Informasi Kebun',

            children: [
              _InfoTile(
                icon: Icons.park_rounded,

                label: 'Nama kebun',

                value: kebun.nama,
              ),

              _InfoTile(
                icon: Icons.location_on_rounded,

                label: 'Lokasi',

                value: kebun.lokasi ?? 'Belum diisi',
              ),

              _InfoTile(
                icon: Icons.straighten_rounded,

                label: 'Luas',

                value: kebun.luas == null ? 'Belum diisi' : '${kebun.luas} Ha',
              ),

              _InfoTile(
                icon: Icons.forest_rounded,

                label: 'Jumlah pohon',

                value: kebun.jumlahPohon == null
                    ? 'Belum diisi'
                    : '${kebun.jumlahPohon} pohon',

                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _DetailSection(
            icon: Icons.notes_rounded,

            title: 'Catatan',

            children: [
              _InfoTile(
                icon: Icons.notes_rounded,

                label: 'Keterangan',

                value: kebun.keterangan ?? 'Belum ada keterangan',

                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _DetailSection(
            icon: Icons.history_rounded,

            title: 'Informasi Data',

            children: [
              _InfoTile(
                icon: Icons.calendar_today_rounded,

                label: 'Dibuat',

                value: _formatDate(kebun.createdAt),
              ),

              _InfoTile(
                icon: Icons.update_rounded,

                label: 'Diperbarui',

                value: _formatDate(kebun.updatedAt),

                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(ColorScheme colors, String status) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF176B3A),

        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.forest_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  kebun.nama,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        kebun.lokasi ?? 'Lokasi belum diisi',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                _StatusBadge(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

// =============================================================
// DETAIL SECTION
// =============================================================

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(21),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,

                decoration: BoxDecoration(
                  color: const Color(0xFFE4F3E9),

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: const Color(0xFF176B3A)),
              ),

              const SizedBox(width: 10),

              Flexible(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }
}

// =============================================================
// INFO TILE
// =============================================================

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 18, color: const Color(0xFF176B3A)),

          const SizedBox(width: 11),

          SizedBox(
            width: 105,

            child: Text(
              label,

              style: const TextStyle(fontSize: 12, color: Color(0xFF7B827D)),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
