import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/kebun_pekerja.dart';
import 'package:nyawit/models/kebun_truk.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/models/panen_pekerja.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/pengangkutan.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/models/biaya_panen.dart';
import 'package:nyawit/models/tarif.dart';
import 'package:nyawit/repositories/biaya_panen_repository.dart';
import 'package:nyawit/repositories/tarif_repository.dart';
import 'package:nyawit/repositories/kebun_pekerja_repository.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/kebun_truk_repository.dart';
import 'package:nyawit/repositories/lokasi_timbang_repository.dart';
import 'package:nyawit/repositories/panen_pekerja_repository.dart';
import 'package:nyawit/repositories/panen_repository.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/pengangkutan_repository.dart';
import 'package:nyawit/repositories/truk_repository.dart';
import 'package:nyawit/screens/panen/panen_detail_page.dart';
import 'package:nyawit/screens/panen/panen_form_page.dart';
import 'package:nyawit/screens/panen/widgets/panen_filter.dart';
import 'package:nyawit/screens/panen/widgets/panen_form_components.dart';
import 'package:nyawit/screens/panen/widgets/panen_hero_card.dart';
import 'package:nyawit/screens/panen/widgets/panen_history_card.dart';

part 'widgets/panen_form_ui.dart';

class PanenPage extends StatefulWidget {
  const PanenPage({super.key, this.kebunId, this.kebunName});

  final int? kebunId;
  final String? kebunName;

  @override
  State<PanenPage> createState() => _PanenPageState();
}

class _PanenPageState extends State<PanenPage> {
  final _repository = PanenRepository();
  final _kebunRepository = KebunRepository();
  final _searchController = TextEditingController();

  late Future<List<Panen>> _future;

  List<Kebun> _kebuns = [];

  DateTime? _filterDate;
  int? _filterKebunId;

  @override
  void initState() {
    super.initState();

    _future = _repository.getAll();
    _filterKebunId = widget.kebunId;

    _loadKebuns();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadKebuns() async {
    final kebuns = await _kebunRepository.getAll();

    if (!mounted) return;

    setState(() {
      _kebuns = kebuns;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repository.getAll();
    });

    await Future.wait([_future, _loadKebuns()]);
  }

  List<Panen> _filtered(List<Panen> items) {
    final query = _searchController.text.trim().toLowerCase();

    return items.where((item) {
      final kebun = _kebunName(item.kebunId).toLowerCase();

      final matchesText = query.isEmpty || kebun.contains(query);

      final matchesKebun =
          _filterKebunId == null || item.kebunId == _filterKebunId;

      final matchesDate =
          _filterDate == null || _sameDay(item.tanggal, _filterDate!);

      return matchesText && matchesKebun && matchesDate;
    }).toList();
  }

  String _kebunName(int id) {
    for (final kebun in _kebuns) {
      if (kebun.id == id) {
        return kebun.nama;
      }
    }

    return 'Kebun tidak ditemukan';
  }

  Future<void> _openForm([Panen? panen]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PanenFormPage(
          panen: panen,
          initialKebunId: panen == null ? widget.kebunId : null,
          lockKebun: widget.kebunId != null,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _delete(Panen panen) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus panen?'),
        content: const Text(
          'Data pekerja dan pengangkutan transaksi ini juga akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || panen.id == null) {
      return;
    }

    await _repository.delete(panen.id!);

    if (mounted) {
      await _refresh();
    }
  }

  Future<void> _openDetail(Panen panen) async {
    if (panen.id == null) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PanenDetailPage(panenId: panen.id!)),
    );

    if (changed == true && mounted) {
      await _refresh();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final scopedKebunName = widget.kebunName ?? _kebunName(widget.kebunId ?? 0);

    final isScopedToKebun = widget.kebunId != null;

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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.onSurface,
                ),
                tooltip: 'Kembali',
              ),
              title: Text(
                widget.kebunName ?? 'Kebun',
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: false,
            ),
      body: FutureBuilder<List<Panen>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: _refresh,
                child: const Text('Coba lagi'),
              ),
            );
          }

          final panens = _filtered(snapshot.data ?? []);

          return RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surfaceContainerHighest,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
              children: [
                PanenHeroCard(
                  count: panens.length,
                  scopedKebunName: isScopedToKebun ? scopedKebunName : null,
                  onAdd: _openForm,
                ),

                const SizedBox(height: 20),

                PanenFilter(
                  searchController: _searchController,
                  kebuns: _kebuns,
                  selectedKebunId: _filterKebunId,
                  selectedDate: _filterDate,
                  isScopedToKebun: isScopedToKebun,
                  scopedKebunName: scopedKebunName,
                  onKebunChanged: (value) {
                    setState(() {
                      _filterKebunId = value;
                    });
                  },
                  onDateChanged: (value) {
                    setState(() {
                      _filterDate = value;
                    });
                  },
                  onDateCleared: () {
                    setState(() {
                      _filterDate = null;
                    });
                  },
                ),

                const SizedBox(height: 24),

                if (panens.isEmpty)
                  PanenEmptyState(
                    hasData: snapshot.data?.isNotEmpty ?? false,
                    onAdd: _openForm,
                  )
                else
                  ...panens.map(
                    (panen) => PanenHistoryCard(
                      panen: panen,
                      kebunName: _kebunName(panen.kebunId),
                      onTap: () {
                        _openDetail(panen);
                      },
                      onEdit: () {
                        _openForm(panen);
                      },
                      onDelete: () {
                        _delete(panen);
                      },
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

String _number(num value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
