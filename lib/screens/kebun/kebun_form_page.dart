import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/kebun_pekerja.dart';
import 'package:nyawit/models/kebun_truk.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/truk.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/kebun_pekerja_repository.dart';
import 'package:nyawit/repositories/kebun_truk_repository.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/truk_repository.dart';
import 'package:nyawit/screens/kebun/forms/kebun_form_fields.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_assignment_widgets.dart';

class KebunFormPage extends StatefulWidget {
  const KebunFormPage({super.key, this.kebun});

  final Kebun? kebun;

  @override
  State<KebunFormPage> createState() => _KebunFormPageState();
}

class _KebunFormPageState extends State<KebunFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _luasController = TextEditingController();
  final _jumlahPohonController = TextEditingController();
  final _keteranganController = TextEditingController();

  final _repository = KebunRepository();
  final _pekerjaRepository = PekerjaRepository();
  final _trukRepository = TrukRepository();
  final _kebunPekerjaRepository = KebunPekerjaRepository();
  final _kebunTrukRepository = KebunTrukRepository();

  List<Pekerja> _pekerja = [];
  List<KebunPekerja> _relations = [];
  List<Truk> _truk = [];
  List<KebunTruk> _trukRelations = [];

  bool _isSaving = false;

  bool get _isEditing => widget.kebun != null;

  @override
  void initState() {
    super.initState();

    final kebun = widget.kebun;

    if (kebun != null) {
      _namaController.text = kebun.nama;
      _lokasiController.text = kebun.lokasi ?? '';
      _luasController.text = kebun.luas?.toString() ?? '';
      _jumlahPohonController.text = kebun.jumlahPohon?.toString() ?? '';
      _keteranganController.text = kebun.keterangan ?? '';
    }

    _loadAssignmentSettings();
  }

  Future<void> _loadAssignmentSettings() async {
    try {
      final results = await Future.wait([
        _pekerjaRepository.getAll(),
        _trukRepository.getAll(),
        widget.kebun?.id == null
            ? Future.value(<KebunPekerja>[])
            : _kebunPekerjaRepository.getByKebunId(widget.kebun!.id!),
        widget.kebun?.id == null
            ? Future.value(<KebunTruk>[])
            : _kebunTrukRepository.getByKebunId(widget.kebun!.id!),
      ]);

      if (!mounted) return;

      setState(() {
        _pekerja = results[0] as List<Pekerja>;
        _truk = results[1] as List<Truk>;
        _relations = results[2] as List<KebunPekerja>;
        _trukRelations = results[3] as List<KebunTruk>;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _luasController.dispose();
    _jumlahPohonController.dispose();
    _keteranganController.dispose();

    super.dispose();
  }

  Future<void> _saveKebun() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final existingKebun = widget.kebun;
      final now = DateTime.now();

      final kebun = Kebun(
        id: existingKebun?.id,
        nama: _namaController.text.trim(),
        lokasi: _lokasiController.text.trim().isEmpty
            ? null
            : _lokasiController.text.trim(),
        luas: _luasController.text.trim().isEmpty
            ? null
            : double.tryParse(_luasController.text.trim().replaceAll(',', '.')),
        jumlahPohon: _jumlahPohonController.text.trim().isEmpty
            ? null
            : int.tryParse(_jumlahPohonController.text.trim()),
        keterangan: _keteranganController.text.trim().isEmpty
            ? null
            : _keteranganController.text.trim(),
        createdAt: existingKebun?.createdAt ?? now,
        updatedAt: now,
      );

      late final int kebunId;

      if (_isEditing) {
        await _repository.update(kebun);
        kebunId = existingKebun!.id!;
      } else {
        kebunId = await _repository.insert(kebun);
      }

      final selectedIds = _relations
          .map((relation) => relation.pekerjaId)
          .toSet();

      for (final relation in _relations) {
        await _kebunPekerjaRepository.save(
          KebunPekerja(
            id: relation.id,
            kebunId: kebunId,
            pekerjaId: relation.pekerjaId,
            isDefault: relation.isDefault,
            aktif: relation.aktif,
            mulai: relation.mulai,
            selesai: relation.selesai,
            keterangan: relation.keterangan,
          ),
        );
      }

      for (final relation in await _kebunPekerjaRepository.getByKebunId(
        kebunId,
      )) {
        if (!selectedIds.contains(relation.pekerjaId)) {
          await _kebunPekerjaRepository.delete(kebunId, relation.pekerjaId);
        }
      }

      final selectedTrukIds = _trukRelations
          .map((relation) => relation.trukId)
          .toSet();

      for (final relation in _trukRelations) {
        await _kebunTrukRepository.save(
          KebunTruk(
            id: relation.id,
            kebunId: kebunId,
            trukId: relation.trukId,
            isDefault: relation.isDefault,
            aktif: relation.aktif,
            mulai: relation.mulai,
            selesai: relation.selesai,
            keterangan: relation.keterangan,
          ),
        );
      }

      for (final relation in await _kebunTrukRepository.getByKebunId(kebunId)) {
        if (!selectedTrukIds.contains(relation.trukId)) {
          await _kebunTrukRepository.delete(kebunId, relation.trukId);
        }
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isEditing
                      ? 'Gagal memperbarui data kebun.'
                      : 'Gagal menyimpan data kebun.',
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerLow,
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Kebun' : 'Tambah Kebun',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 1000,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  KebunFormHeroCard(isEditing: _isEditing),

                  const SizedBox(height: 28),

                  KebunFormSectionHeader(
                    icon: Icons.eco_rounded,
                    title: 'Informasi Kebun',
                    subtitle: 'Lengkapi informasi dasar kebun',
                    colors: colors,
                  ),

                  const SizedBox(height: 14),

                  KebunFormInput(
                    controller: _namaController,
                    label: 'Nama kebun',
                    hint: 'Contoh: Kebun Balam Jaya',
                    icon: Icons.park_rounded,
                    colors: colors,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama kebun wajib diisi';
                      }

                      if (value.trim().length < 3) {
                        return 'Minimal 3 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  KebunFormInput(
                    controller: _lokasiController,
                    label: 'Lokasi kebun',
                    hint: 'Desa, kecamatan, atau kabupaten',
                    icon: Icons.location_on_rounded,
                    colors: colors,
                  ),

                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 430;

                      final luas = KebunFormInput(
                        controller: _luasController,
                        label: 'Luas',
                        hint: '245',
                        icon: Icons.straighten_rounded,
                        suffix: 'Ha',
                        colors: colors,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final luas = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );

                          if (luas == null) return 'Tidak valid';
                          if (luas <= 0) return 'Harus > 0';

                          return null;
                        },
                      );

                      final pohon = KebunFormInput(
                        controller: _jumlahPohonController,
                        label: 'Pohon',
                        hint: '18000',
                        icon: Icons.forest_rounded,
                        suffix: 'pohon',
                        colors: colors,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final jumlah = int.tryParse(value.trim());

                          if (jumlah == null) return 'Tidak valid';
                          if (jumlah <= 0) return 'Harus > 0';

                          return null;
                        },
                      );

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [luas, const SizedBox(height: 12), pohon],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: luas),
                          const SizedBox(width: 12),
                          Expanded(child: pohon),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  KebunFormSectionHeader(
                    icon: Icons.notes_rounded,
                    title: 'Catatan',
                    subtitle: 'Tambahkan informasi tambahan',
                    colors: colors,
                  ),

                  const SizedBox(height: 12),

                  KebunFormInput(
                    controller: _keteranganController,
                    label: 'Keterangan',
                    hint: 'Contoh: Kebun produksi utama...',
                    icon: Icons.notes_rounded,
                    colors: colors,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 28),

                  _buildWorkerSettings(colors),

                  const SizedBox(height: 28),

                  _buildTrukSettings(colors),

                  const SizedBox(height: 28),

                  KebunFormSaveButton(
                    isSaving: _isSaving,
                    isEditing: _isEditing,
                    onPressed: _saveKebun,
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Data tersimpan secara offline di perangkat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSettings(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KebunFormSectionHeader(
          icon: Icons.engineering_rounded,
          title: 'Pekerja Kebun',
          subtitle: 'Hubungkan pekerja dan atur default/aktif',
          colors: colors,
        ),
        const SizedBox(height: 12),
        if (_pekerja.isEmpty)
          KebunAssignmentEmptyState(
            colors: colors,
            icon: Icons.groups_outlined,
            message:
                'Belum ada data pekerja. Tambahkan pekerja dari menu Lainnya.',
          )
        else
          KebunAssignmentGroup(
            colors: colors,
            children: _pekerja.map((pekerja) {
              KebunPekerja? relation;

              for (final item in _relations) {
                if (item.pekerjaId == pekerja.id) {
                  relation = item;
                }
              }

              final connected = relation != null;

              return _buildWorkerRow(colors, pekerja, relation, connected);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildWorkerRow(
    ColorScheme colors,
    Pekerja pekerja,
    KebunPekerja? relation,
    bool connected,
  ) {
    final currentRelation = relation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: connected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _relations.add(
                        KebunPekerja(
                          kebunId: widget.kebun?.id ?? 0,
                          pekerjaId: pekerja.id!,
                          isDefault: _relations.isEmpty,
                          aktif: true,
                        ),
                      );
                    } else {
                      _relations.removeWhere(
                        (item) => item.pekerjaId == pekerja.id,
                      );
                    }
                  });
                },
                activeColor: colors.primary,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pekerja.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pekerja.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (currentRelation != null &&
                            currentRelation.isDefault == true) ...[
                          const SizedBox(width: 8),
                          KebunAssignmentStatusPill(
                            label: 'Default',
                            icon: Icons.star_rounded,
                            color: isDark
                                ? const Color(0xFFF1CC75)
                                : Colors.amber.shade700,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentRelation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    title: Text(
                      currentRelation.aktif ? 'Aktif' : 'Tidak aktif',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: currentRelation.aktif,
                    onChanged: (value) {
                      setState(() {
                        _replaceRelation(currentRelation, aktif: value);
                      });
                    },
                    activeThumbColor: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Jadikan default',
                  onPressed: currentRelation.isDefault
                      ? null
                      : () => setState(() {
                          _relations = _relations
                              .map(
                                (item) => _replaceRelationValue(
                                  item,
                                  isDefault: item.pekerjaId == pekerja.id,
                                ),
                              )
                              .toList();
                        }),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(42, 42),
                    padding: EdgeInsets.zero,
                    backgroundColor: currentRelation.isDefault
                        ? (isDark
                              ? const Color(0xFFF1CC75).withValues(alpha: 0.14)
                              : Colors.amber.withValues(alpha: 0.12))
                        : colors.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                    foregroundColor: currentRelation.isDefault
                        ? (isDark
                              ? const Color(0xFFF1CC75)
                              : Colors.amber.shade700)
                        : colors.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    currentRelation.isDefault
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 19,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _replaceRelation(KebunPekerja relation, {required bool aktif}) {
    _relations = _relations
        .map(
          (item) => item.pekerjaId == relation.pekerjaId
              ? _replaceRelationValue(item, aktif: aktif)
              : item,
        )
        .toList();
  }

  KebunPekerja _replaceRelationValue(
    KebunPekerja relation, {
    bool? isDefault,
    bool? aktif,
  }) {
    return KebunPekerja(
      id: relation.id,
      kebunId: relation.kebunId,
      pekerjaId: relation.pekerjaId,
      isDefault: isDefault ?? relation.isDefault,
      aktif: aktif ?? relation.aktif,
      mulai: relation.mulai,
      selesai: relation.selesai,
      keterangan: relation.keterangan,
    );
  }

  Widget _buildTrukSettings(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KebunFormSectionHeader(
          icon: Icons.local_shipping_rounded,
          title: 'Truk Bertugas',
          subtitle: 'Opsional. Tambahkan truk dan atur truk default kebun.',
          colors: colors,
        ),
        const SizedBox(height: 12),
        if (_truk.isEmpty)
          KebunAssignmentEmptyState(
            colors: colors,
            icon: Icons.local_shipping_outlined,
            message: 'Belum ada data truk. Tambahkan truk dari menu Lainnya.',
          )
        else
          KebunAssignmentGroup(
            colors: colors,
            children: _truk.map((truk) {
              KebunTruk? relation;

              for (final item in _trukRelations) {
                if (item.trukId == truk.id) {
                  relation = item;
                }
              }

              final connected = relation != null;

              return _buildTrukRow(colors, truk, relation, connected);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTrukRow(
    ColorScheme colors,
    Truk truk,
    KebunTruk? relation,
    bool connected,
  ) {
    final currentRelation = relation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: connected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _trukRelations = _trukRelations
                          .map(
                            (item) => _replaceTrukRelationValue(
                              item,
                              isDefault: false,
                            ),
                          )
                          .toList();

                      _trukRelations.add(
                        KebunTruk(
                          kebunId: widget.kebun?.id ?? 0,
                          trukId: truk.id!,
                          // Truk baru langsung menjadi default kebun.
                          isDefault: true,
                          aktif: true,
                        ),
                      );
                    } else {
                      _trukRelations.removeWhere(
                        (item) => item.trukId == truk.id,
                      );
                    }
                  });
                },
                activeColor: colors.primary,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truk.jenis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${truk.namaSupir} • ${truk.status}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (currentRelation != null && currentRelation.isDefault == true)
                KebunAssignmentStatusPill(
                  label: 'Default',
                  icon: Icons.star_rounded,
                  color: isDark
                      ? const Color(0xFFF1CC75)
                      : Colors.amber.shade700,
                ),
            ],
          ),
          if (currentRelation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    title: Text(
                      currentRelation.aktif ? 'Aktif bertugas' : 'Tidak aktif',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: currentRelation.aktif,
                    onChanged: (value) {
                      setState(() {
                        _replaceTrukRelation(currentRelation, aktif: value);
                      });
                    },
                    activeThumbColor: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Jadikan default',
                  onPressed: currentRelation.isDefault
                      ? null
                      : () => setState(() {
                          _trukRelations = _trukRelations
                              .map(
                                (item) => _replaceTrukRelationValue(
                                  item,
                                  isDefault: item.trukId == truk.id,
                                ),
                              )
                              .toList();
                        }),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(42, 42),
                    padding: EdgeInsets.zero,
                    backgroundColor: currentRelation.isDefault
                        ? (isDark
                              ? const Color(0xFFF1CC75).withValues(alpha: 0.14)
                              : Colors.amber.withValues(alpha: 0.12))
                        : colors.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                    foregroundColor: currentRelation.isDefault
                        ? (isDark
                              ? const Color(0xFFF1CC75)
                              : Colors.amber.shade700)
                        : colors.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    currentRelation.isDefault
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: 'Hapus dari kebun',
                  onPressed: () => setState(() {
                    _trukRelations.removeWhere(
                      (item) => item.trukId == truk.id,
                    );
                  }),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(42, 42),
                    padding: EdgeInsets.zero,
                    foregroundColor: colors.error,
                    backgroundColor: colors.error.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _replaceTrukRelation(KebunTruk relation, {required bool aktif}) {
    _trukRelations = _trukRelations
        .map(
          (item) => item.trukId == relation.trukId
              ? _replaceTrukRelationValue(item, aktif: aktif)
              : item,
        )
        .toList();
  }

  KebunTruk _replaceTrukRelationValue(
    KebunTruk relation, {
    bool? isDefault,
    bool? aktif,
  }) {
    return KebunTruk(
      id: relation.id,
      kebunId: relation.kebunId,
      trukId: relation.trukId,
      isDefault: isDefault ?? relation.isDefault,
      aktif: aktif ?? relation.aktif,
      mulai: relation.mulai,
      selesai: relation.selesai,
      keterangan: relation.keterangan,
    );
  }
}
