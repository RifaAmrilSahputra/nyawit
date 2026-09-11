import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/produk.dart';
import 'package:nyawit/models/kebun_pekerja.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/kegiatan_perawatan_pekerja.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/produk_repository.dart';
import 'package:nyawit/repositories/tarif_perawatan_repository.dart';
import 'package:nyawit/repositories/kebun_pekerja_repository.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_pekerja_repository.dart';

class PerawatanFormPage extends StatefulWidget {
  const PerawatanFormPage({
    super.key,
    this.kegiatan,
    this.initialKebunId,
    this.lockKebun = false,
  });

  final KegiatanPerawatan? kegiatan;
  final int? initialKebunId;
  final bool lockKebun;

  @override
  State<PerawatanFormPage> createState() => _PerawatanFormPageState();
}

class _PerawatanFormPageState extends State<PerawatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _kebunRepo = KebunRepository();
  final _produkRepo = ProdukRepository();
  final _tarifRepo = TarifPerawatanRepository();
  final _kebunPekerjaRepo = KebunPekerjaRepository();
  final _pekerjaRepo = PekerjaRepository();
  final _kpRepo = KegiatanPerawatanPekerjaRepository();
  final _repo = KegiatanPerawatanRepository();

  JenisPerawatan _jenis = JenisPerawatan.pupuk;

  int? _kebunId;
  Kebun? _kebun;
  List<Kebun> _kebuns = [];

  int? _produkId;
  List<Produk> _produkList = [];

  List<KebunPekerja> _kebunPekerjaRelations = [];
  List<Pekerja> _allPekerja = [];
  final Set<int> _selectedPekerjaIds = {};

  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _satuanController = TextEditingController();
  final _tarifController = TextEditingController();
  final _totalController = TextEditingController();
  final _dibayarController = TextEditingController(text: '0');
  final _keteranganController = TextEditingController();

  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _kebunId = widget.initialKebunId ?? widget.kegiatan?.kebunId;
    _jenis = widget.kegiatan?.jenis ?? JenisPerawatan.pupuk;
    _tanggalMulai = widget.kegiatan?.tanggalMulai ?? DateTime.now();
    _tanggalSelesai = widget.kegiatan?.tanggalSelesai ?? _tanggalMulai;
    _loadInitials();
  }

  Future<void> _loadInitials() async {
    final results = await Future.wait([
      _kebunRepo.getAll(),
      _produkRepo.getAll(),
      _pekerjaRepo.getAll(),
    ]);
    final kebuns = results[0] as List<Kebun>;
    final produks = results[1] as List<Produk>;
    final pekerjas = results[2] as List<Pekerja>;

    if (!mounted) return;
    setState(() {
      _kebuns = kebuns;
      _produkList = produks;
      _allPekerja = pekerjas;
    });

    if (_kebunId != null) {
      await _onKebunChanged(_kebunId!);
    }
    if (widget.kegiatan != null) {
      _populateFromExisting(widget.kegiatan!);
    }
  }

  void _populateFromExisting(KegiatanPerawatan k) async {
    _namaController.text = k.namaKegiatan ?? '';
    _produkId = k.produkId;
    if (k.jumlah != null) {
      _jumlahController.text = k.jumlah!.toString();
    }
    if (k.satuan != null) {
      _satuanController.text = k.satuan!;
    }
    if (k.tarifSatuan != null) {
      _tarifController.text = k.tarifSatuan!.toString();
    }
    _totalController.text = k.totalBiaya.toString();
    _dibayarController.text = k.dibayarkan.toString();
    _keteranganController.text = k.keterangan ?? '';
    _tanggalMulai = k.tanggalMulai;
    _tanggalSelesai = k.tanggalSelesai;
    final pekerja = await _kpRepo.getByKegiatanId(k.id!);
    setState(() {
      _selectedPekerjaIds.addAll(pekerja.map((e) => e.pekerjaId));
    });
  }

  Future<void> _onKebunChanged(int kebunId) async {
    _kebun = await _kebunRepo.getById(kebunId);
    _kebunId = kebunId;
    _kebunPekerjaRelations = await _kebunPekerjaRepo.getByKebunId(kebunId);
    for (final rel in _kebunPekerjaRelations) {
      if (rel.isDefault == true) {
        _selectedPekerjaIds.add(rel.pekerjaId);
      }
    }
    await _loadDefaultTarifAndProduk();
    setState(() {});
  }

  Future<void> _loadDefaultTarifAndProduk() async {
    if (_jenis == JenisPerawatan.tunas) {
      final t = await _tarifRepo.getFor(
        JenisPerawatan.tunas,
        kebunId: _kebunId,
      );
      if (t != null) {
        _tarifController.text = t.tarif.toString();
      }
      if (_kebun?.jumlahPohon != null) {
        _jumlahController.text = '${_kebun!.jumlahPohon}';
      }
    }
    if (_kebun?.luas != null && _jenis == JenisPerawatan.semprot) {
      _jumlahController.text = '${_kebun!.luas}';
    }
    _recalculateTotal();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kebunId == null) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();

      double? jumlah = _jumlahController.text.trim().isEmpty
          ? null
          : double.tryParse(_jumlahController.text.replaceAll(',', '.'));
      final satuan = _satuanController.text.trim().isEmpty
          ? null
          : _satuanController.text.trim();
      final tarifSatuan = _tarifController.text.trim().isEmpty
          ? null
          : double.tryParse(_tarifController.text.replaceAll(',', '.'));
      final totalBiaya =
          double.tryParse(_totalController.text.replaceAll(',', '.')) ?? 0;
      final dibayarkan =
          double.tryParse(_dibayarController.text.replaceAll(',', '.')) ?? 0;

      final kegiatan = KegiatanPerawatan(
        kebunId: _kebunId!,
        jenis: _jenis,
        namaKegiatan: _namaController.text.trim().isEmpty
            ? null
            : _namaController.text.trim(),
        tanggalMulai: _tanggalMulai,
        tanggalSelesai: _tanggalSelesai,
        produkId: _produkId,
        jumlah: jumlah,
        satuan: satuan,
        tarifSatuan: tarifSatuan,
        totalBiaya: totalBiaya,
        dibayarkan: dibayarkan,
        keterangan: _keteranganController.text.trim().isEmpty
            ? null
            : _keteranganController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      if (widget.kegiatan == null) {
        final id = await _repo.insert(kegiatan);
        final relations = _selectedPekerjaIds
            .map(
              (pid) => KegiatanPerawatanPekerja(
                kegiatanPerawatanId: id,
                pekerjaId: pid,
              ),
            )
            .toList();
        await _kpRepo.replaceRelations(id, relations);
      } else {
        final updated = kegiatan.copyWith(
          id: widget.kegiatan!.id,
          createdAt: widget.kegiatan!.createdAt,
        );
        await _repo.update(updated);
        final relations = _selectedPekerjaIds
            .map(
              (pid) => KegiatanPerawatanPekerja(
                kegiatanPerawatanId: widget.kegiatan!.id!,
                pekerjaId: pid,
              ),
            )
            .toList();
        await _kpRepo.replaceRelations(widget.kegiatan!.id!, relations);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan perawatan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormSection(
                title: 'Informasi umum',
                icon: Icons.info_outline_rounded,
                children: [
                  DropdownButtonFormField<JenisPerawatan>(
                    initialValue: _jenis,
                    isExpanded: true,
                    items: JenisPerawatan.values
                        .map(
                          (j) =>
                              DropdownMenuItem(value: j, child: Text(j.label)),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _jenis = v);
                      await _loadDefaultTarifAndProduk();
                    },
                    decoration: _inputDecoration(
                      context,
                      'Jenis Perawatan',
                      Icons.category_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _kebunId,
                    isExpanded: true,
                    items: _kebuns
                        .map(
                          (k) => DropdownMenuItem(
                            value: k.id,
                            child: Text(k.nama),
                          ),
                        )
                        .toList(),
                    onChanged: widget.lockKebun
                        ? null
                        : (v) async {
                            if (v == null) return;
                            await _onKebunChanged(v);
                          },
                    decoration: _inputDecoration(
                      context,
                      'Kebun',
                      Icons.park_rounded,
                    ),
                    validator: (v) => v == null ? 'Kebun wajib dipilih' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaController,
                    decoration: _inputDecoration(
                      context,
                      'Nama Kegiatan (opsional)',
                      Icons.edit_note_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggalMulai,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _tanggalMulai = picked;
                                if (_tanggalSelesai.isBefore(_tanggalMulai)) {
                                  _tanggalSelesai = _tanggalMulai;
                                }
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              context,
                              'Tanggal Mulai',
                              Icons.calendar_today_rounded,
                            ),
                            child: Text(
                              _tanggalMulai
                                  .toLocal()
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggalSelesai,
                              firstDate: _tanggalMulai,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _tanggalSelesai = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              context,
                              'Tanggal Selesai',
                              Icons.event_available_rounded,
                            ),
                            child: Text(
                              _tanggalSelesai
                                  .toLocal()
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: 'Detail kegiatan',
                icon: Icons.assignment_rounded,
                children: [
                  if (_jenis == JenisPerawatan.pupuk ||
                      _jenis == JenisPerawatan.semprot) ...[
                    DropdownButtonFormField<int>(
                      initialValue: _produkId,
                      isExpanded: true,
                      items: _produkList
                          .where((p) => p.aktif)
                          .where(
                            (p) => _jenis == JenisPerawatan.pupuk
                                ? p.jenis == 'pupuk'
                                : p.jenis == 'semprot',
                          )
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nama),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _produkId = v);
                        if (_kebunId == null) return;
                        final t = await _tarifRepo.getFor(
                          _jenis,
                          kebunId: _kebunId,
                          produkId: _produkId,
                        );
                        if (t != null) {
                          _tarifController.text = t.tarif.toString();
                        }
                        final prod = _produkList.firstWhere(
                          (e) => e.id == _produkId,
                          orElse: () => Produk(
                            id: null,
                            nama: '',
                            jenis: '',
                            satuanDefault: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                        _satuanController.text = prod.satuanDefault;
                        _recalculateTotal();
                      },
                      decoration: _inputDecoration(
                        context,
                        'Produk',
                        Icons.inventory_2_rounded,
                      ),
                      validator: (v) =>
                          (_jenis == JenisPerawatan.pupuk ||
                                  _jenis == JenisPerawatan.semprot) &&
                              v == null
                          ? 'Produk wajib dipilih'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_jenis == JenisPerawatan.tunas) ...[
                    TextFormField(
                      controller: _jumlahController,
                      decoration: _inputDecoration(
                        context,
                        'Jumlah Pohon',
                        Icons.numbers_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'Jumlah > 0';
                        return null;
                      },
                      onChanged: (_) => _recalculateTotal(),
                    ),
                    const SizedBox(height: 12),
                  ] else if (_jenis == JenisPerawatan.semprot) ...[
                    TextFormField(
                      controller: _jumlahController,
                      decoration: _inputDecoration(
                        context,
                        'Luas Pekerjaan (ha)',
                        Icons.straighten_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                      ],
                      validator: (v) {
                        final val = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (val == null || val <= 0) return 'Luas > 0';
                        if (_kebun?.luas != null && val > _kebun!.luas!) {
                          return 'Luas tidak boleh melebihi luas kebun';
                        }
                        return null;
                      },
                      onChanged: (_) => _recalculateTotal(),
                    ),
                    const SizedBox(height: 12),
                  ] else if (_jenis == JenisPerawatan.pupuk) ...[
                    TextFormField(
                      controller: _jumlahController,
                      decoration: _inputDecoration(
                        context,
                        'Jumlah (${_satuanController.text.isEmpty ? 'unit' : _satuanController.text})',
                        Icons.scale_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                      ],
                      validator: (v) {
                        final val = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (val == null || val <= 0) return 'Jumlah > 0';
                        return null;
                      },
                      onChanged: (_) => _recalculateTotal(),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    TextFormField(
                      controller: _totalController,
                      decoration: _inputDecoration(
                        context,
                        'Total Biaya (Rp)',
                        Icons.receipt_long_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                      ],
                      validator: (v) {
                        final val = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (val == null || val < 0) {
                          return 'Total biaya tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_jenis != JenisPerawatan.lainnya) ...[
                    TextFormField(
                      controller: _tarifController,
                      decoration: _inputDecoration(
                        context,
                        'Tarif/Satuan (Rp)',
                        Icons.attach_money_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                      ],
                      validator: (v) {
                        final val = double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        );
                        if (val == null || val < 0) {
                          return 'Tarif tidak boleh negatif';
                        }
                        return null;
                      },
                      onChanged: (_) => _recalculateTotal(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _totalController,
                    decoration: _inputDecoration(
                      context,
                      'Total Biaya (Rp)',
                      Icons.account_balance_wallet_rounded,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                    ],
                    validator: (v) {
                      final val = double.tryParse(
                        (v ?? '').replaceAll(',', '.'),
                      );
                      if (val == null || val < 0) {
                        return 'Total biaya tidak valid';
                      }
                      return null;
                    },
                    readOnly: _jenis != JenisPerawatan.lainnya,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: 'Pembayaran',
                icon: Icons.payments_rounded,
                children: [
                  TextFormField(
                    controller: _dibayarController,
                    decoration:
                        _inputDecoration(
                          context,
                          'Dibayarkan (Rp)',
                          Icons.payments_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            tooltip: 'Bayar sesuai total',
                            onPressed: () {
                              final total =
                                  double.tryParse(
                                    _totalController.text.replaceAll(',', '.'),
                                  ) ??
                                  0;
                              setState(
                                () =>
                                    _dibayarController.text = total.toString(),
                              );
                            },
                            icon: const Icon(Icons.auto_fix_high_rounded),
                          ),
                        ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                    ],
                    validator: (v) {
                      final val = double.tryParse(
                        (v ?? '').replaceAll(',', '.'),
                      );
                      if (val == null || val < 0) {
                        return 'Pembayaran tidak valid';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_kebunPekerjaRelations.isNotEmpty) ...[
                _FormSection(
                  title: 'Tim kerja',
                  icon: Icons.groups_rounded,
                  children: [
                    ..._kebunPekerjaRelations.map((rel) {
                      final p = _allPekerja.firstWhere(
                        (e) => e.id == rel.pekerjaId,
                        orElse: () => Pekerja(
                          id: rel.pekerjaId,
                          nama: 'Pekerja',
                          status: 'aktif',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      final active = rel.aktif == true;
                      return CheckboxListTile(
                        value: _selectedPekerjaIds.contains(rel.pekerjaId),
                        onChanged: active
                            ? (v) => setState(
                                () => v == true
                                    ? _selectedPekerjaIds.add(rel.pekerjaId)
                                    : _selectedPekerjaIds.remove(rel.pekerjaId),
                              )
                            : null,
                        title: Text(p.nama),
                        subtitle: rel.isDefault == true
                            ? const Text('Default')
                            : null,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              _FormSection(
                title: 'Keterangan',
                icon: Icons.notes_rounded,
                children: [
                  TextFormField(
                    controller: _keteranganController,
                    decoration: _inputDecoration(
                      context,
                      'Keterangan',
                      Icons.notes_rounded,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perawatan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colors.primary),
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  void _recalculateTotal() {
    if (_jenis == JenisPerawatan.lainnya) return;
    final jumlah =
        double.tryParse(_jumlahController.text.replaceAll(',', '.')) ?? 0;
    final tarif =
        double.tryParse(_tarifController.text.replaceAll(',', '.')) ?? 0;
    final total = jumlah * tarif;
    _totalController.text = total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _satuanController.dispose();
    _tarifController.dispose();
    _totalController.dispose();
    _dibayarController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
