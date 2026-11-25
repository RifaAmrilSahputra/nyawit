import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_item_card.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_search.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_summary_card.dart';

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
            color: colors.primary,
            onRefresh: _refresh,

            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),

              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),

              children: [
                KebunSummaryCard(kebuns: allKebuns, onAdd: _openFormAndRefresh),

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

                      child: KebunItemCard(
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
}

// =============================================================
// =============================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.forest_rounded,
                size: 45,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Belum ada kebun',

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Tambahkan kebun pertama untuk mulai '
              'mengelola data perkebunan.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onAdd,

              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,

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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 50),

      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 50,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 12),

          Text(
            'Kebun tidak ditemukan',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Coba gunakan nama atau lokasi lain.',

            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
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
    final colors = Theme.of(context).colorScheme;

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
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: colors.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Gagal memuat data',

              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Terjadi masalah saat mengambil data kebun.',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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

List<Color> _legacyHeaderGradient(ColorScheme colors, bool isDark) {
  if (isDark) {
    return const [Color(0xFF123B2D), Color(0xFF205640)];
  }
  return [colors.primary, Color.lerp(colors.primary, colors.tertiary, .42)!];
}

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

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,

        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        title: Text(
          'Detail Kebun',

          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: IconButton(
              onPressed: () => _editKebun(context),

              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.primary,
              ),

              icon: const Icon(Icons.edit_rounded, size: 20),
            ),
          ),
        ],
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),

        children: [
          _buildDetailHeader(
            colors,
            Theme.of(context).brightness == Brightness.dark,
          ),

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

  Widget _buildDetailHeader(ColorScheme colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _legacyHeaderGradient(colors, isDark),
        ),

        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .14),

            blurRadius: 18,

            offset: const Offset(0, 7),
          ),
        ],
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,

        borderRadius: BorderRadius.circular(21),

        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
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
                  color: colors.secondaryContainer,

                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(icon, size: 19, color: colors.primary),
              ),

              const SizedBox(width: 10),

              Flexible(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 18, color: colors.primary),

          const SizedBox(width: 11),

          SizedBox(
            width: 105,

            child: Text(
              label,

              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,

              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
