import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';
import 'package:nyawit/screens/perawatan/perawatan_form_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_detail_page.dart';

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
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                tooltip: 'Kembali',
              ),
              title: Text(widget.kebunName ?? 'Kebun'),
              centerTitle: false,
            ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.primary,
        displacement: 18,

        child: _isLoading
            ? const _LoadingView()
            : ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
                children: [
                  _SummaryCard(
                    count: _filteredItems.length,
                    totalBiaya: _totalFilteredBiaya,
                    totalDibayarkan: _totalDibayarkan,
                    onAdd: () => _openForm(),
                  ),

                  const SizedBox(height: 18),

                  _SearchField(
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

                  _FilterRow(
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
                        child: _PerawatanCard(
                          item: item,
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
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        controller: TextEditingController(text: query)
          ..selection = TextSelection.collapsed(offset: query.length),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Cari kegiatan perawatan...',
          hintStyle: TextStyle(
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 21,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER ROW
// ============================================================

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedKebunId,
    required this.selectedJenis,
    required this.kebuns,
    required this.onKebunChanged,
    required this.onJenisChanged,
  });

  final int? selectedKebunId;
  final JenisPerawatan? selectedJenis;
  final List<Kebun> kebuns;

  final ValueChanged<int?> onKebunChanged;
  final ValueChanged<JenisPerawatan?> onJenisChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KebunDropdown(
            selectedKebunId: selectedKebunId,
            kebuns: kebuns,
            onChanged: onKebunChanged,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _JenisDropdown(
            selectedJenis: selectedJenis,
            onChanged: onJenisChanged,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// KEBUN DROPDOWN
// ============================================================

class _KebunDropdown extends StatelessWidget {
  const _KebunDropdown({
    required this.selectedKebunId,
    required this.kebuns,
    required this.onChanged,
  });

  final int? selectedKebunId;
  final List<Kebun> kebuns;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedKebunId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.onSurfaceVariant,
          ),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: colors.surfaceContainer,

          hint: Row(
            children: [
              Icon(Icons.park_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kebun',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          selectedItemBuilder: (context) {
            return [
              _DropdownSelectedLabel(icon: Icons.park_rounded, text: 'Kebun'),
              ...kebuns.map(
                (kebun) => _DropdownSelectedLabel(
                  icon: Icons.park_rounded,
                  text: kebun.nama,
                ),
              ),
            ];
          },

          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Semua Kebun', style: TextStyle(fontSize: 13)),
            ),

            ...kebuns.map(
              (kebun) => DropdownMenuItem<int?>(
                value: kebun.id,
                child: Text(
                  kebun.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],

          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================
// JENIS DROPDOWN
// ============================================================

class _JenisDropdown extends StatelessWidget {
  const _JenisDropdown({required this.selectedJenis, required this.onChanged});

  final JenisPerawatan? selectedJenis;
  final ValueChanged<JenisPerawatan?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JenisPerawatan?>(
          value: selectedJenis,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.onSurfaceVariant,
          ),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: colors.surfaceContainer,

          hint: Row(
            children: [
              Icon(Icons.category_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Jenis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          selectedItemBuilder: (context) {
            return [
              _DropdownSelectedLabel(
                icon: Icons.category_rounded,
                text: 'Jenis',
              ),
              ...JenisPerawatan.values.map(
                (jenis) => _DropdownSelectedLabel(
                  icon: Icons.category_rounded,
                  text: jenis.label,
                ),
              ),
            ];
          },

          items: [
            const DropdownMenuItem<JenisPerawatan?>(
              value: null,
              child: Text('Semua Jenis', style: TextStyle(fontSize: 13)),
            ),

            ...JenisPerawatan.values.map(
              (jenis) => DropdownMenuItem<JenisPerawatan?>(
                value: jenis,
                child: Text(
                  jenis.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],

          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================
// DROPDOWN SELECTED LABEL
// ============================================================

class _DropdownSelectedLabel extends StatelessWidget {
  const _DropdownSelectedLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.totalBiaya,
    required this.totalDibayarkan,
    required this.onAdd,
  });

  final int count;
  final double totalBiaya;
  final double totalDibayarkan;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final remaining = totalBiaya - totalDibayarkan;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, const Color(0xFF25834A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.bloodtype_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Perawatan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$count kegiatan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Color(0xFF176B3A),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryValue(
                        label: 'Total biaya',
                        value: _currency(totalBiaya),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: _SummaryValue(
                          label: 'Dibayarkan',
                          value: _currency(totalDibayarkan),
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: _SummaryValue(
                          label: 'Sisa',
                          value: _currency(remaining < 0 ? 0 : remaining),
                        ),
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
}

// ============================================================
// SUMMARY VALUE
// ============================================================

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PERAWATAN CARD
// ============================================================

class _PerawatanCard extends StatelessWidget {
  const _PerawatanCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final KegiatanPerawatan item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final title = item.namaKegiatan ?? item.jenis.label;

    final paymentLabel = _paymentLabel(item.statusPembayaran);
    final paymentColor = _paymentColor(item.statusPembayaran, colors);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),

        child: Ink(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(21),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),

            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActivityIcon(jenis: item.jenis),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            _ActionMenu(onEdit: onEdit, onDelete: onDelete),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.park_rounded,
                              size: 14,
                              color: colors.primary,
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                'Kebun ${item.kebunId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CardInfo(
                        icon: Icons.calendar_month_rounded,
                        label: 'Tanggal',
                        value: _dateRange(
                          item.tanggalMulai,
                          item.tanggalSelesai,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _CardInfo(
                        icon: Icons.payments_rounded,
                        label: 'Biaya',
                        value: _currency(item.totalBiaya),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _StatusChip(
                    icon: _jenisIcon(item.jenis),
                    label: item.jenis.label,
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                  ),

                  const SizedBox(width: 7),

                  Flexible(
                    child: _StatusChip(
                      icon: _paymentIcon(item.statusPembayaran),
                      label: paymentLabel,
                      backgroundColor: paymentColor.withValues(alpha: 0.11),
                      foregroundColor: paymentColor,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACTIVITY ICON
// ============================================================

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.jenis});

  final JenisPerawatan jenis;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        _jenisIcon(jenis),
        color: colors.onPrimaryContainer,
        size: 23,
      ),
    );
  }
}

// ============================================================
// ACTION MENU
// ============================================================

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',

      icon: const Icon(Icons.more_horiz_rounded, size: 21),

      padding: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },

      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 10),
              Text('Edit'),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18),
              SizedBox(width: 10),
              Text('Hapus'),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CARD INFO
// ============================================================

class _CardInfo extends StatelessWidget {
  const _CardInfo({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: colors.primary),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),

      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foregroundColor),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
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
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _currency(num value) {
  return 'Rp${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), (match) => '.')}';
}

String _dateRange(DateTime start, DateTime end) {
  final startDate = start.toLocal();
  final endDate = end.toLocal();

  final startText =
      '${startDate.day.toString().padLeft(2, '0')}/'
      '${startDate.month.toString().padLeft(2, '0')}/'
      '${startDate.year}';

  final endText =
      '${endDate.day.toString().padLeft(2, '0')}/'
      '${endDate.month.toString().padLeft(2, '0')}/'
      '${endDate.year}';

  return '$startText - $endText';
}

String _paymentLabel(String? status) {
  switch (status) {
    case 'lunas':
      return 'Lunas';

    case 'kurang_bayar':
      return 'Sebagian / DP';

    case 'lebih_bayar':
      return 'Lebih bayar';

    default:
      return 'Belum bayar';
  }
}

Color _paymentColor(String? status, ColorScheme colors) {
  switch (status) {
    case 'lunas':
      return colors.primary;

    case 'kurang_bayar':
      return Colors.orange.shade700;

    case 'lebih_bayar':
      return Colors.blue.shade700;

    default:
      return Colors.red.shade700;
  }
}

IconData _paymentIcon(String? status) {
  switch (status) {
    case 'lunas':
      return Icons.check_circle_rounded;

    case 'kurang_bayar':
      return Icons.warning_amber_rounded;

    case 'lebih_bayar':
      return Icons.add_circle_outline_rounded;

    default:
      return Icons.pending_rounded;
  }
}

IconData _jenisIcon(JenisPerawatan jenis) {
  switch (jenis) {
    case JenisPerawatan.pupuk:
      return Icons.grass_rounded;

    case JenisPerawatan.tunas:
      return Icons.auto_fix_high_rounded;

    case JenisPerawatan.semprot:
      return Icons.local_florist_rounded;

    default:
      return Icons.miscellaneous_services_rounded;
  }
}
