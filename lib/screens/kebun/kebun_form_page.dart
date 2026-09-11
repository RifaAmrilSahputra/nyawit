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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          ),
        ),

        title: Text(
          _isEditing ? 'Edit Kebun' : 'Tambah Kebun',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),

      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          // Keep this compact form mounted while scrolling through optional
          // worker/truck assignments, preserving form state and validation.
          cacheExtent: 1000,

          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroHeader(colors),

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

                  const SizedBox(height: 14),

                  _buildInput(
                    controller: _lokasiController,
                    label: 'Lokasi kebun',
                    hint: 'Desa, kecamatan, atau kabupaten',
                    icon: Icons.location_on_rounded,
                    colors: colors,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInput(
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

                            if (luas == null) {
                              return 'Tidak valid';
                            }

                            if (luas <= 0) {
                              return 'Harus > 0';
                            }

                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildInput(
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

                            if (jumlah == null) {
                              return 'Tidak valid';
                            }

                            if (jumlah <= 0) {
                              return 'Harus > 0';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _buildSectionHeader(
                    icon: Icons.notes_rounded,
                    title: 'Catatan',
                    subtitle: 'Tambahkan informasi tambahan',
                    colors: colors,
                  ),

                  const SizedBox(height: 14),

                  _buildInput(
                    controller: _keteranganController,
                    label: 'Keterangan',
                    hint: 'Contoh: Kebun produksi utama...',
                    icon: Icons.notes_rounded,
                    colors: colors,
                    maxLines: 5,
                  ),

                  const SizedBox(height: 30),

                  _buildWorkerSettings(colors),

                  const SizedBox(height: 30),

                  _buildSaveButton(colors),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'Data tersimpan secara offline di perangkat',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildTrukSettings(colors),
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
        _buildSectionHeader(
          icon: Icons.engineering_rounded,
          title: 'Pekerja Kebun',
          subtitle: 'Hubungkan pekerja dan atur default/aktif',
          colors: colors,
        ),
        const SizedBox(height: 12),
        if (_pekerja.isEmpty)
          Text(
            'Belum ada data pekerja. Tambahkan pekerja dari menu Lainnya.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          )
        else
          ..._pekerja.map((pekerja) {
            KebunPekerja? relation;
            for (final item in _relations) {
              if (item.pekerjaId == pekerja.id) relation = item;
            }
            final connected = relation != null;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
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
                    title: Text(
                      pekerja.nama,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(pekerja.status),
                    activeColor: const Color(0xFF176B3A),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (connected)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Aktif',
                                style: TextStyle(fontSize: 13),
                              ),
                              value: relation.aktif,
                              onChanged: (value) {
                                setState(() {
                                  _replaceRelation(relation!, aktif: value);
                                });
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Jadikan default',
                            onPressed: relation.isDefault
                                ? null
                                : () => setState(() {
                                    _relations = _relations
                                        .map(
                                          (item) => _replaceRelationValue(
                                            item,
                                            isDefault:
                                                item.pekerjaId == pekerja.id,
                                          ),
                                        )
                                        .toList();
                                  }),
                            icon: Icon(
                              relation.isDefault
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: relation.isDefault
                                  ? Colors.amber.shade700
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
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
        _buildSectionHeader(
          icon: Icons.local_shipping_rounded,
          title: 'Truk Bertugas',
          subtitle: 'Opsional. Tambahkan truk dan atur truk default kebun.',
          colors: colors,
        ),
        const SizedBox(height: 12),
        if (_truk.isEmpty)
          Text(
            'Belum ada data truk. Tambahkan truk dari menu Lainnya.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          )
        else
          ..._truk.map((truk) {
            KebunTruk? relation;
            for (final item in _trukRelations) {
              if (item.trukId == truk.id) relation = item;
            }
            final connected = relation != null;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
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
                    title: Text(
                      truk.jenis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${truk.namaSupir} • ${truk.status}'),
                    activeColor: const Color(0xFF176B3A),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (connected)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Aktif bertugas',
                                style: TextStyle(fontSize: 13),
                              ),
                              value: relation.aktif,
                              onChanged: (value) {
                                setState(() {
                                  _replaceTrukRelation(relation!, aktif: value);
                                });
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Jadikan default',
                            onPressed: relation.isDefault
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
                            icon: Icon(
                              relation.isDefault
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: relation.isDefault
                                  ? Colors.amber.shade700
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus dari kebun',
                            onPressed: () => setState(() {
                              _trukRelations.removeWhere(
                                (item) => item.trukId == truk.id,
                              );
                            }),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
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

  Widget _buildHeroHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF176B3A),
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF176B3A).withValues(alpha: 0.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Icon(
                  Icons.forest_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Perbarui kebun' : 'Kebun baru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _isEditing
                          ? 'Periksa data sebelum menyimpan perubahan.'
                          : 'Tambahkan kebun untuk mulai mengelola data.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5,
                        height: 1.4,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colors,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: const Color(0xFFE2F2E8),
            borderRadius: BorderRadius.circular(13),
          ),

          child: Icon(icon, size: 21, color: const Color(0xFF176B3A)),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colors,
    String? suffix,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,

      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,

      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(icon, size: 21),
        ),

        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          minHeight: 50,
        ),

        suffixText: suffix,

        suffixStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),

        labelStyle: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),

        hintStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.onSurfaceVariant.withValues(alpha: 0.55),
        ),

        filled: true,
        fillColor: colors.surfaceContainerLow,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        prefixIconColor: const Color(0xFF176B3A),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF176B3A), width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),

        errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isSaving ? null : _saveKebun,

        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF176B3A),
          disabledBackgroundColor: const Color(
            0xFF176B3A,
          ).withValues(alpha: 0.55),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),

          child: _isSaving
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('button'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 22),

                    const SizedBox(width: 9),

                    Text(
                      _isEditing ? 'Simpan Perubahan' : 'Simpan Kebun',
                      style: const TextStyle(
                        fontSize: 15,
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
