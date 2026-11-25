import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/produk.dart';
import 'package:nyawit/models/kebun_pekerja.dart';
import 'package:nyawit/models/pekerja.dart';
import 'package:nyawit/models/kegiatan_perawatan_pekerja.dart';
import 'package:nyawit/models/status_kegiatan_perawatan.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/produk_repository.dart';
import 'package:nyawit/repositories/tarif_perawatan_repository.dart';
import 'package:nyawit/repositories/kebun_pekerja_repository.dart';
import 'package:nyawit/repositories/pekerja_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_repository.dart';
import 'package:nyawit/repositories/kegiatan_perawatan_pekerja_repository.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_form_components.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_selection_field.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_kebunId == null) {
      return;
    }

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
        statusKegiatan:
            widget.kegiatan?.statusKegiatan ?? StatusKegiatan.rencana,
        keterangan: _keteranganController.text.trim().isEmpty
            ? null
            : _keteranganController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      if (widget.kegiatan == null) {
        final id = await _repo.insert(kegiatan);

        await _repo.addStatusHistory(
          StatusKegiatanPerawatan(
            kegiatanPerawatanId: id,
            status: StatusKegiatan.rencana.value,
            tanggal: _tanggalMulai,
            keterangan: 'Status awal',
            createdAt: now,
            updatedAt: now,
          ),
        );

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

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan perawatan.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final width = MediaQuery.sizeOf(context).width;

    final isWide = width >= 760;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.maybePop(context),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              backgroundColor: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          ),
        ),
        titleSpacing: 4,
        title: Text(
          widget.kegiatan == null ? 'Perawatan baru' : 'Edit perawatan',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -.25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isWide ? 28 : 16,
          10,
          isWide ? 28 : 16,
          40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PerawatanFormHeroCard(),

                  const SizedBox(height: 24),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildGeneralSection(context)),
                        const SizedBox(width: 18),
                        Expanded(child: _buildDetailsSection(context)),
                      ],
                    )
                  else ...[
                    _buildGeneralSection(context),
                    const SizedBox(height: 16),
                    _buildDetailsSection(context),
                  ],

                  if (_kebunPekerjaRelations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildTeamSection(context),
                  ],

                  const SizedBox(height: 16),

                  _buildNotesSection(context),

                  const SizedBox(height: 24),

                  _buildSaveButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return PerawatanFormSectionCard(
      title: 'Informasi umum',
      icon: Icons.tune_rounded,
      subtitle: 'Tentukan jenis, kebun, dan periode pekerjaan.',
      children: [
        const PerawatanFormFieldCaption(text: 'JENIS PERAWATAN'),
        const SizedBox(height: 7),
        _buildJenisField(context),

        const SizedBox(height: 14),

        const PerawatanFormFieldCaption(text: 'KEBUN'),
        const SizedBox(height: 7),
        _buildKebunField(context),

        const SizedBox(height: 14),

        const PerawatanFormFieldCaption(text: 'NAMA KEGIATAN'),
        const SizedBox(height: 7),
        TextFormField(
          controller: _namaController,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            context,
            'Nama kegiatan',
            Icons.edit_note_rounded,
            hintText: 'Contoh: Pemupukan blok A',
          ),
        ),

        const SizedBox(height: 16),

        const PerawatanFormFieldCaption(text: 'PERIODE'),
        const SizedBox(height: 8),

        _buildDateFields(context),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return PerawatanFormSectionCard(
      title: 'Detail pekerjaan',
      icon: Icons.assignment_rounded,
      subtitle: 'Atur bahan, jumlah, tarif, dan biaya pekerjaan.',
      children: [
        if (_jenis == JenisPerawatan.pupuk ||
            _jenis == JenisPerawatan.semprot) ...[
          const PerawatanFormFieldCaption(text: 'PRODUK'),
          const SizedBox(height: 7),
          _buildProdukField(context),
          const SizedBox(height: 14),
        ],

        const PerawatanFormFieldCaption(text: 'JUMLAH'),
        const SizedBox(height: 7),
        _buildJumlahField(context),

        if (_jenis != JenisPerawatan.lainnya) ...[
          const SizedBox(height: 14),
          const PerawatanFormFieldCaption(text: 'TARIF / SATUAN'),
          const SizedBox(height: 7),
          _buildTarifField(context),
        ],

        const SizedBox(height: 18),

        _buildTotalSummary(context),
      ],
    );
  }

  Widget _buildTotalSummary(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PerawatanTotalCostCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colors.primary,
                  size: 17,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'TOTAL BIAYA',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .55,
                  ),
                ),
              ),

              if (_jenis != JenisPerawatan.lainnya)
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.primary.withValues(alpha: .7),
                  size: 17,
                ),
            ],
          ),

          const SizedBox(height: 9),

          _buildTotalField(context),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return PerawatanFormSectionCard(
      title: 'Catatan lapangan',
      icon: Icons.notes_rounded,
      subtitle: 'Tambahkan informasi tambahan jika diperlukan.',
      children: [
        TextFormField(
          controller: _keteranganController,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            context,
            'Keterangan',
            Icons.notes_rounded,
            hintText: 'Tambahkan catatan kegiatan...',
          ),
          maxLines: 4,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FilledButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: Icon(_isSaving ? Icons.hourglass_top_rounded : Icons.check_rounded),
      label: Text(_isSaving ? 'Menyimpan...' : 'Simpan perawatan'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.primary.withValues(alpha: .45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildJenisField(BuildContext context) =>
      PerawatanSelectionField<JenisPerawatan>(
        options: JenisPerawatan.values
            .map(
              (item) => PerawatanSelectionOption<JenisPerawatan>(
                value: item,
                label: item.label,
                icon: Icons.category_rounded,
              ),
            )
            .toList(),
        value: _jenis,
        placeholder: 'Jenis perawatan',
        title: 'Pilih Jenis Perawatan',
        icon: Icons.category_rounded,
        isRequired: true,
        onChanged: (value) async {
          if (value == null) return;

          setState(() => _jenis = value);

          await _loadDefaultTarifAndProduk();
        },
      );

  Widget _buildKebunField(BuildContext context) => PerawatanSelectionField<int>(
    options: _kebuns
        .map(
          (item) => PerawatanSelectionOption<int>(
            value: item.id,
            label: item.nama,
            subtitle: item.lokasi,
            icon: Icons.forest_rounded,
          ),
        )
        .toList(),
    value: _kebunId,
    placeholder: 'Kebun',
    title: 'Pilih Kebun',
    icon: Icons.park_rounded,
    enabled: !widget.lockKebun,
    showLockIcon: widget.lockKebun,
    isRequired: true,
    onChanged: (value) async {
      if (value != null) {
        await _onKebunChanged(value);
      }
    },
  );

  Widget _buildDateFields(BuildContext context) {
    Widget field(
      String label,
      IconData icon,
      DateTime date,
      VoidCallback onTap,
    ) {
      return Expanded(
        child: PerawatanPeriodTile(
          label: label,
          icon: icon,
          dateLabel: _formatDate(date),
          onTap: onTap,
        ),
      );
    }

    final start = field(
      'Tanggal mulai',
      Icons.calendar_today_rounded,
      _tanggalMulai,
      () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _tanggalMulai,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() {
            _tanggalMulai = picked;

            if (_tanggalSelesai.isBefore(picked)) {
              _tanggalSelesai = picked;
            }
          });
        }
      },
    );

    final end = field(
      'Tanggal selesai',
      Icons.event_available_rounded,
      _tanggalSelesai,
      () async {
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
    );

    if (MediaQuery.sizeOf(context).width >= 560) {
      return Row(children: [start, const SizedBox(width: 10), end]);
    }

    return Column(
      children: [
        Row(children: [start]),
        const SizedBox(height: 10),
        Row(children: [end]),
      ],
    );
  }

  Widget _buildProdukField(BuildContext context) =>
      PerawatanSelectionField<int>(
        options: _produkList
            .where(
              (item) =>
                  item.aktif &&
                  (_jenis == JenisPerawatan.pupuk
                      ? item.jenis == 'pupuk'
                      : item.jenis == 'semprot'),
            )
            .map(
              (item) => PerawatanSelectionOption<int>(
                value: item.id,
                label: item.nama,
                subtitle: item.satuanDefault,
                icon: Icons.inventory_2_rounded,
              ),
            )
            .toList(),
        value: _produkId,
        placeholder: 'Produk',
        title: 'Pilih Produk',
        icon: Icons.inventory_2_rounded,
        isRequired: true,
        onChanged: (value) async {
          setState(() => _produkId = value);

          if (_kebunId == null) {
            return;
          }

          final tarif = await _tarifRepo.getFor(
            _jenis,
            kebunId: _kebunId,
            produkId: value,
          );

          if (tarif != null) {
            _tarifController.text = tarif.tarif.toString();
          }

          final product = _produkList.firstWhere((item) => item.id == value);

          _satuanController.text = product.satuanDefault;

          _recalculateTotal();
        },
      );

  Widget _buildJumlahField(BuildContext context) {
    final isTunas = _jenis == JenisPerawatan.tunas;

    final isSemprot = _jenis == JenisPerawatan.semprot;

    if (_jenis == JenisPerawatan.lainnya) {
      return TextFormField(
        controller: _totalController,
        decoration: _inputDecoration(
          context,
          'Total biaya',
          Icons.receipt_long_rounded,
          prefixText: 'Rp ',
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
        ],
        validator: (value) =>
            double.tryParse((value ?? '').replaceAll(',', '.')) == null
            ? 'Total biaya tidak valid'
            : null,
      );
    }

    final label = isTunas
        ? 'Jumlah pohon'
        : isSemprot
        ? 'Luas pekerjaan'
        : 'Jumlah';

    final suffix = isTunas
        ? 'pohon'
        : isSemprot
        ? 'ha'
        : (_satuanController.text.isEmpty ? 'unit' : _satuanController.text);

    return TextFormField(
      controller: _jumlahController,
      decoration: _inputDecoration(
        context,
        label,
        isSemprot ? Icons.straighten_rounded : Icons.scale_rounded,
        suffixText: suffix,
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: !isTunas),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(isTunas ? r'[0-9]' : r'[0-9\.,]'),
        ),
      ],
      validator: (value) {
        final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));

        if (parsed == null || parsed <= 0) {
          return '$label harus lebih dari 0';
        }

        if (isSemprot && _kebun?.luas != null && parsed > _kebun!.luas!) {
          return 'Luas tidak boleh melebihi luas kebun';
        }

        return null;
      },
      onChanged: (_) => _recalculateTotal(),
    );
  }

  Widget _buildTarifField(BuildContext context) => TextFormField(
    controller: _tarifController,
    decoration: _inputDecoration(
      context,
      'Tarif / satuan',
      Icons.payments_outlined,
      prefixText: 'Rp ',
    ),
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
    validator: (value) =>
        double.tryParse((value ?? '').replaceAll(',', '.')) == null
        ? 'Tarif tidak boleh negatif'
        : null,
    onChanged: (_) => _recalculateTotal(),
  );

  Widget _buildTotalField(BuildContext context) => TextFormField(
    controller: _totalController,
    readOnly: _jenis != JenisPerawatan.lainnya,
    decoration: _inputDecoration(
      context,
      'Total biaya',
      Icons.account_balance_wallet_rounded,
      prefixText: 'Rp ',
      isTotal: true,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
    validator: (value) =>
        double.tryParse((value ?? '').replaceAll(',', '.')) == null
        ? 'Total biaya tidak valid'
        : null,
    style: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w800,
      letterSpacing: -.3,
      color: Theme.of(context).colorScheme.primary,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );

  Widget _buildTeamSection(BuildContext context) => PerawatanFormSectionCard(
    title: 'Tim kerja',
    icon: Icons.groups_rounded,
    subtitle: 'Pilih pekerja yang terlibat dalam kegiatan ini.',
    children: _kebunPekerjaRelations.map((relation) {
      final worker = _allPekerja.firstWhere(
        (item) => item.id == relation.pekerjaId,
      );

      return PerawatanWorkerTile(
        name: worker.nama,
        isSelected: _selectedPekerjaIds.contains(relation.pekerjaId),
        isActive: relation.aktif == true,
        isDefault: relation.isDefault == true,
        onChanged: relation.aktif == true
            ? (value) => setState(
                () => value == true
                    ? _selectedPekerjaIds.add(relation.pekerjaId)
                    : _selectedPekerjaIds.remove(relation.pekerjaId),
              )
            : null,
      );
    }).toList(),
  );

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    IconData icon, {
    String? hintText,
    String? prefixText,
    String? suffixText,
    bool isTotal = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      prefixIcon: Icon(
        icon,
        color: isTotal ? colors.primary : colors.onSurfaceVariant,
        size: 20,
      ),
      filled: true,
      fillColor: colors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: .45),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: .45),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: colors.primary.withValues(alpha: .8),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: colors.error.withValues(alpha: .7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: colors.error, width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    );
  }

  void _recalculateTotal() {
    if (_jenis == JenisPerawatan.lainnya) {
      return;
    }

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
    _keteranganController.dispose();

    super.dispose();
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} '
      '${date.year}';
}
