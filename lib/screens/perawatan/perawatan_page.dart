import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';
import 'package:nyawit/screens/perawatan/perawatan_form_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_detail_page.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_activity_card.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_filters.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_summary_card.dart';

class PerawatanPage extends StatefulWidget {
  const PerawatanPage({super.key, this.kebunId, this.kebunName});

  final int? kebunId;
  final String? kebunName;

  @override
  State<PerawatanPage> createState() => _PerawatanPageState();
}

class _PerawatanPageState extends State<PerawatanPage> {
  final _repo = KegiatanPerawatanRepository();
  final _kebunRepo = KebunRepository();

  List<KegiatanPerawatan> _items = [];
  List<Kebun> _kebuns = [];

  int? _selectedKebunId;
  JenisPerawatan? _selectedJenis;
  String _query = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _selectedKebunId = widget.kebunId;

    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _kebunRepo.getAll(),
        _repo.getAll(kebunId: _selectedKebunId),
      ]);

      if (!mounted) return;

      setState(() {
        _kebuns = results[0] as List<Kebun>;
        _items = results[1] as List<KegiatanPerawatan>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  Future<void> _openForm([KegiatanPerawatan? kegiatan]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PerawatanFormPage(
          kegiatan: kegiatan,
          initialKebunId: _selectedKebunId,
          lockKebun: _selectedKebunId != null,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _openDetail(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PerawatanDetailPage(kegiatanId: id)),
    );

    if (mounted) {
      await _loadData();
    }
  }

  Future<void> _delete(int id) async {
    await _repo.delete(id);

    if (mounted) {
      await _loadData();
    }
  }

  List<KegiatanPerawatan> get _filteredItems {
    var list = _items;

    if (_selectedJenis != null) {
      list = list.where((item) => item.jenis == _selectedJenis).toList();
    }

    if (_query.isNotEmpty) {
      final query = _query.toLowerCase();

      list = list.where((item) {
        final name = (item.namaKegiatan ?? item.jenis.label).toLowerCase();

        return name.contains(query);
      }).toList();
    }

    return list;
  }

  double get _totalFilteredBiaya {
    return _filteredItems.fold(0.0, (sum, item) => sum + item.totalBiaya);
  }

  double get _totalDibayarkan {
    return _filteredItems.fold(0.0, (sum, item) => sum + item.totalDibayar);
  }

  String _kebunName(int id) {
    for (final kebun in _kebuns) {
      if (kebun.id == id) return kebun.nama;
    }
    return 'Kebun $id';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: widget.kebunId == null
          ? AppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 18,
            )
          : AppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.onSurface,
                ),
                tooltip: 'Kembali',
              ),
              title: Text(
                widget.kebunName ?? 'Kebun',
                style: TextStyle(color: colors.onSurface),
              ),
              centerTitle: false,
            ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.primary,
        backgroundColor: colors.surface,
        displacement: 18,

        child: _isLoading
            ? const _LoadingView()
            : ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 112),
                children: [
                  PerawatanSummaryCard(
                    count: _filteredItems.length,
                    totalBiaya: _totalFilteredBiaya,
                    totalDibayarkan: _totalDibayarkan,
                    onAdd: () => _openForm(),
                  ),

                  const SizedBox(height: 18),

                  PerawatanSearchField(
                    query: _query,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _query = '';
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  PerawatanFilterRow(
                    selectedKebunId: _selectedKebunId,
                    selectedJenis: _selectedJenis,
                    kebuns: _kebuns,
                    onKebunChanged: (value) {
                      setState(() {
                        _selectedKebunId = value;
                      });

                      _loadData();
                    },
                    onJenisChanged: (value) {
                      setState(() {
                        _selectedJenis = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  if (_filteredItems.isEmpty)
                    _EmptyState(
                      hasFilter:
                          _query.isNotEmpty ||
                          _selectedKebunId != null ||
                          _selectedJenis != null,
                      onAdd: () => _openForm(),
                      onReset: _resetFilters,
                    )
                  else
                    ..._filteredItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PerawatanActivityCard(
                          item: item,
                          kebunName: _kebunName(item.kebunId),
                          onTap: () => _openDetail(item.id!),
                          onEdit: () => _openForm(item),
                          onDelete: () async {
                            if (item.id != null) {
                              await _delete(item.id!);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _selectedKebunId = widget.kebunId;
      _selectedJenis = null;
    });

    _loadData();
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilter,
    required this.onAdd,
    required this.onReset,
  });

  final bool hasFilter;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.medical_services_rounded,
              size: 34,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            hasFilter ? 'Data tidak ditemukan' : 'Belum ada data perawatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            hasFilter
                ? 'Coba ubah kata pencarian atau filter yang digunakan.'
                : 'Mulai dengan menambahkan kegiatan perawatan baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          if (hasFilter)
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Reset Filter'),
            )
          else
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Perawatan'),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 112),
      children: [
        _SkeletonBox(height: 190, borderRadius: 23),

        const SizedBox(height: 18),

        _SkeletonBox(height: 54, borderRadius: 17),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 50, borderRadius: 15)),
            const SizedBox(width: 10),
            Expanded(child: _SkeletonBox(height: 50, borderRadius: 15)),
          ],
        ),

        const SizedBox(height: 20),

        _SkeletonBox(height: 220, borderRadius: 21),

        const SizedBox(height: 12),

        _SkeletonBox(height: 220, borderRadius: 21),

        const SizedBox(height: 12),

        _SkeletonBox(height: 220, borderRadius: 21),
      ],
    );
  }
}

// ============================================================
// SKELETON
// ============================================================

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.borderRadius});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
