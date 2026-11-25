part of '../panen_page.dart';

class PanenFormPageImplementation extends StatefulWidget {
  const PanenFormPageImplementation({
    super.key,
    this.panen,
    this.initialKebunId,
    this.lockKebun = false,
  });

  final Panen? panen;
  final int? initialKebunId;
  final bool lockKebun;

  @override
  State<PanenFormPageImplementation> createState() => _PanenFormPageState();
}

class _PanenFormPageState extends State<PanenFormPageImplementation> {
  final _formKey = GlobalKey<FormState>();
  final _panenRepository = PanenRepository();
  final _kebunRepository = KebunRepository();
  final _pekerjaRepository = PekerjaRepository();
  final _trukRepository = TrukRepository();
  final _lokasiRepository = LokasiTimbangRepository();
  final _kebunPekerjaRepository = KebunPekerjaRepository();
  final _kebunTrukRepository = KebunTrukRepository();
  final _panenPekerjaRepository = PanenPekerjaRepository();
  final _pengangkutanRepository = PengangkutanRepository();
  final _tarifRepository = TarifRepository();
  final _biayaRepository = BiayaPanenRepository();
  final _beratController = TextEditingController();
  final _hargaController = TextEditingController();
  final _sortirController = TextEditingController();
  final _keteranganController = TextEditingController();
  final Map<int, TextEditingController> _trukWeightControllers = {};
  final Map<TarifJenis, TextEditingController> _paymentControllers = {};
  List<BiayaPanen> _biayaSnapshot = [];

  List<Kebun> _kebuns = [];
  List<Pekerja> _pekerja = [];
  List<Truk> _truks = [];
  List<LokasiTimbang> _lokasi = [];
  List<KebunPekerja> _kebunPekerja = [];
  List<KebunTruk> _kebunTruk = [];
  Set<int> _selectedPekerja = {};
  Set<int> _selectedTruk = {};
  int? _kebunId;
  int? _lokasiId;
  DateTime _tanggal = DateTime.now();
  ShippingMethod _method = ShippingMethod.antar;
  bool _loading = true;
  bool _saving = false;

  bool get _editing => widget.panen != null;

  @override
  void initState() {
    super.initState();
    final panen = widget.panen;
    if (panen != null) {
      _kebunId = panen.kebunId;
      _lokasiId = panen.lokasiTimbangId;
      _tanggal = panen.tanggal;
      _method = panen.shippingMethod;
      _beratController.text = _number(panen.beratBersih);
      _hargaController.text = _number(panen.hargaSawit);
      _sortirController.text = panen.sortir == 0 ? '' : _number(panen.sortir);
      _keteranganController.text = panen.keterangan ?? '';
    } else {
      _kebunId = widget.initialKebunId;
    }
    _load();
  }

  Future<void> _load() async {
    final panenId = widget.panen?.id;
    final results = await Future.wait([
      _kebunRepository.getAll(),
      _pekerjaRepository.getAll(),
      _trukRepository.getAll(),
      _lokasiRepository.getAll(),
      if (panenId != null)
        _panenPekerjaRepository.getByPanenId(panenId)
      else
        Future.value(<PanenPekerja>[]),
      if (panenId != null)
        _pengangkutanRepository.getByPanenId(panenId)
      else
        Future.value(<Pengangkutan>[]),
      if (panenId != null)
        _biayaRepository.getByPanenId(panenId)
      else
        Future.value(<BiayaPanen>[]),
    ]);
    if (!mounted) return;
    _kebuns = results[0] as List<Kebun>;
    _pekerja = results[1] as List<Pekerja>;
    _truks = results[2] as List<Truk>;
    _lokasi = results[3] as List<LokasiTimbang>;
    final savedPekerja = results[4] as List<PanenPekerja>;
    final savedPengangkutan = results[5] as List<Pengangkutan>;
    _biayaSnapshot = results[6] as List<BiayaPanen>;
    for (final biaya in _biayaSnapshot) {
      _paymentControllers[biaya.jenis] = TextEditingController(
        text: _number(biaya.jumlahDibayarkan),
      );
    }
    if (_editing) {
      _selectedPekerja = savedPekerja.map((item) => item.pekerjaId).toSet();
      _selectedTruk = savedPengangkutan.map((item) => item.trukId).toSet();
      for (final item in savedPengangkutan) {
        _trukWeightControllers[item.trukId] = TextEditingController(
          text: _number(item.beratBersih),
        );
      }
    }
    if (_kebunId != null) await _loadKebunRelations(applyDefaults: !_editing);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadKebunRelations({required bool applyDefaults}) async {
    final id = _kebunId;
    if (id == null) {
      _kebunPekerja = [];
      _kebunTruk = [];
      return;
    }
    final relations = await Future.wait([
      _kebunPekerjaRepository.getByKebunId(id),
      _kebunTrukRepository.getByKebunId(id),
    ]);
    if (!mounted) return;
    _kebunPekerja = (relations[0] as List<KebunPekerja>)
        .where((item) => item.aktif)
        .toList();
    _kebunTruk = (relations[1] as List<KebunTruk>)
        .where((item) => item.aktif)
        .toList();
    if (applyDefaults) {
      _selectedPekerja = _kebunPekerja
          .where((item) => item.isDefault)
          .map((item) => item.pekerjaId)
          .toSet();
      _selectedTruk = _kebunTruk
          .where((item) => item.isDefault)
          .map((item) => item.trukId)
          .toSet();
      for (final id in _selectedTruk) {
        _trukWeightControllers.putIfAbsent(id, TextEditingController.new);
      }
    }
  }

  List<Pekerja> get _availablePekerja {
    final ids = _kebunPekerja.map((item) => item.pekerjaId).toSet()
      ..addAll(_selectedPekerja);
    return _pekerja
        .where(
          (item) =>
              ids.contains(item.id) &&
              (item.status.toLowerCase() == 'aktif' ||
                  _selectedPekerja.contains(item.id)),
        )
        .toList();
  }

  List<Truk> get _availableTruk {
    final defaultIds = _kebunTruk
        .where((item) => item.isDefault)
        .map((item) => item.trukId)
        .toSet();
    final available = _truks
        .where(
          (item) =>
              item.status.toLowerCase() == 'aktif' ||
              _selectedTruk.contains(item.id),
        )
        .toList();
    available.sort((a, b) {
      final aDefault = defaultIds.contains(a.id);
      final bDefault = defaultIds.contains(b.id);
      if (aDefault != bDefault) return aDefault ? -1 : 1;
      return a.jenis.toLowerCase().compareTo(b.jenis.toLowerCase());
    });
    return available;
  }

  bool _isDefaultTruk(int trukId) =>
      _kebunTruk.any((item) => item.trukId == trukId && item.isDefault);

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final berat = _parse(_beratController.text);
    final harga = _parse(_hargaController.text);
    final sortir = _parse(_sortirController.text);
    if (_method == ShippingMethod.antar) {
      final total = _selectedTruk.length == 1
          ? berat
          : _selectedTruk.fold<double>(
              0,
              (sum, id) => sum + _parse(_trukWeightControllers[id]?.text ?? ''),
            );
      if (_selectedTruk.isEmpty || (total - berat).abs() > .001) {
        _message(
          _selectedTruk.isEmpty
              ? 'Pilih minimal satu truk untuk metode Antar.'
              : 'Total berat seluruh truk harus sama dengan Berat Bersih Panen.',
        );
        return;
      }
    }
    setState(() => _saving = true);
    try {
      final existing = widget.panen;
      final now = DateTime.now();
      final panen = Panen(
        id: existing?.id,
        kebunId: _kebunId!,
        tanggal: _tanggal,
        beratBersih: berat,
        hargaSawit: harga,
        sortir: sortir,
        shippingMethod: _method,
        lokasiTimbangId: _lokasiId,
        keterangan: _keteranganController.text.trim().isEmpty
            ? null
            : _keteranganController.text.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      final pekerja = _selectedPekerja
          .map((id) => PanenPekerja(panenId: existing?.id ?? 0, pekerjaId: id))
          .toList();
      final pengangkutan = _method == ShippingMethod.antar
          ? _selectedTruk
                .map(
                  (id) => Pengangkutan(
                    panenId: existing?.id ?? 0,
                    trukId: id,
                    beratBersih: _selectedTruk.length == 1
                        ? berat
                        : _parse(_trukWeightControllers[id]?.text ?? ''),
                  ),
                )
                .toList()
          : <Pengangkutan>[];
      final biaya = await _buildBiaya(panen, now);
      final pembayaran = <TarifJenis, double>{
        for (final item in biaya)
          item.jenis: _parse(_paymentControllers[item.jenis]?.text ?? ''),
      };
      if (existing == null) {
        await _panenRepository.insertWithRelations(
          panen,
          pekerja,
          pengangkutan,
          biaya: biaya,
          pembayaran: pembayaran,
        );
      } else {
        await _panenRepository.updateWithRelations(
          panen,
          pekerja,
          pengangkutan,
          biaya: biaya,
          pembayaran: pembayaran,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      _message('Gagal menyimpan transaksi panen.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<List<BiayaPanen>> _buildBiaya(Panen panen, DateTime now) async {
    final existing = {for (final item in _biayaSnapshot) item.jenis: item};
    final upah =
        existing[TarifJenis.upahPanen]?.tarifPerKg ??
        await _tarifRepository.nilaiUntuk(
          TarifJenis.upahPanen,
          kebunId: panen.kebunId,
        );
    final truk =
        existing[TarifJenis.ongkosTruk]?.tarifPerKg ??
        await _tarifRepository.nilaiUntuk(TarifJenis.ongkosTruk);
    final muat =
        existing[TarifJenis.biayaMuat]?.tarifPerKg ??
        await _tarifRepository.nilaiUntuk(TarifJenis.biayaMuat);
    final entries = <TarifJenis, double>{TarifJenis.upahPanen: upah};
    if (panen.shippingMethod == ShippingMethod.antar) {
      entries.addAll({TarifJenis.ongkosTruk: truk, TarifJenis.biayaMuat: muat});
    }
    return entries.entries
        .map(
          (entry) => BiayaPanen(
            panenId: panen.id ?? 0,
            jenis: entry.key,
            tarifPerKg: entry.value,
            totalBiaya: panen.beratBersih * entry.value,
            jumlahDibayarkan: _parse(
              _paymentControllers[entry.key]?.text ?? '',
            ),
            createdAt: existing[entry.key]?.createdAt ?? now,
            updatedAt: now,
          ),
        )
        .toList();
  }

  Future<List<BiayaPanen>> _previewBiaya() async {
    if (_kebunId == null) return [];
    final now = DateTime.now();
    return _buildBiaya(
      Panen(
        kebunId: _kebunId!,
        tanggal: _tanggal,
        beratBersih: _parse(_beratController.text),
        hargaSawit: 0,
        sortir: 0,
        shippingMethod: _method,
        createdAt: now,
        updatedAt: now,
      ),
      now,
    );
  }

  Future<void> _addLokasiTimbang() async {
    final lokasi = await showDialog<LokasiTimbang>(
      context: context,
      builder: (_) => const _LokasiTimbangDialog(),
    );
    if (lokasi == null) return;
    try {
      final id = await _lokasiRepository.insert(lokasi);
      final items = await _lokasiRepository.getAll();
      if (mounted) {
        setState(() {
          _lokasi = items;
          _lokasiId = id;
        });
      }
    } catch (_) {
      if (mounted) _message('Gagal menambahkan lokasi timbang.');
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );

  @override
  void dispose() {
    _beratController.dispose();
    _hargaController.dispose();
    _sortirController.dispose();
    _keteranganController.dispose();
    for (final controller in _trukWeightControllers.values) {
      controller.dispose();
    }
    for (final controller in _paymentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 58,
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
          _editing ? 'Edit Panen' : 'Tambah Panen',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            _section(
              'Informasi Panen',
              Icons.eco_rounded,
              subtitle: 'Tentukan tanggal dan kebun untuk transaksi ini.',
            ),
            const SizedBox(height: 14),
            _dateField(context),
            const SizedBox(height: 12),
            PanenGardenSelector(
              kebuns: _kebuns,
              selectedKebunId: _kebunId,
              enabled: !widget.lockKebun,
              onChanged: (value) async {
                if (value == _kebunId) return;
                setState(() {
                  _kebunId = value;
                  _selectedPekerja = {};
                  _selectedTruk = {};
                  for (final controller in _trukWeightControllers.values) {
                    controller.dispose();
                  }
                  _trukWeightControllers.clear();
                });
                await _loadKebunRelations(applyDefaults: true);
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 28),

            _section(
              'Hasil Panen',
              Icons.monitor_weight_rounded,
              subtitle: 'Masukkan berat dan harga transaksi.',
            ),
            const SizedBox(height: 14),
            _responsiveWeightPriceFields(context),
            const SizedBox(height: 12),
            _field(
              _sortirController,
              'Sortir (opsional)',
              'Kg',
              validator: _nonNegative,
              helperText: 'Catatan Kg sortir; tidak mengurangi berat bersih.',
              icon: Icons.filter_alt_outlined,
            ),
            const SizedBox(height: 28),

            _section(
              'Metode & Lokasi',
              Icons.local_shipping_rounded,
              subtitle: 'Pilih cara pengiriman dan lokasi timbang.',
            ),
            const SizedBox(height: 14),
            SegmentedButton<ShippingMethod>(
              segments: const [
                ButtonSegment(
                  value: ShippingMethod.antar,
                  label: Text('Antar'),
                  icon: Icon(Icons.local_shipping_rounded, size: 18),
                ),
                ButtonSegment(
                  value: ShippingMethod.lapangan,
                  label: Text('Lapangan'),
                  icon: Icon(Icons.landscape_rounded, size: 18),
                ),
              ],
              selected: {_method},
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size.fromHeight(46)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 14),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onSelectionChanged: (value) =>
                  setState(() => _method = value.first),
            ),
            const SizedBox(height: 12),
            PanenWeighbridgeSelector(
              lokasi: _lokasi,
              selectedLokasiId: _lokasiId,
              onChanged: (value) => setState(() => _lokasiId = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addLokasiTimbang,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text(
                  _lokasi.isEmpty
                      ? 'Tambah lokasi timbang terlebih dahulu'
                      : 'Tambah lokasi timbang baru',
                ),
              ),
            ),
            const SizedBox(height: 24),

            _section(
              'Pekerja',
              Icons.engineering_rounded,
              subtitle: 'Pilih kebun untuk memuat pekerja aktif.',
            ),
            const SizedBox(height: 10),
            if (_kebunId == null)
              _contextState(
                icon: Icons.info_outline_rounded,
                text: 'Pilih kebun untuk memuat pekerja aktif.',
              )
            else if (_availablePekerja.isEmpty)
              _contextState(
                icon: Icons.person_off_outlined,
                text: 'Tidak ada pekerja aktif yang terhubung ke kebun ini.',
              )
            else
              ..._availablePekerja.map((item) => _workerTile(item)),
            const SizedBox(height: 24),

            if (_method == ShippingMethod.antar) ...[
              _section(
                'Pengangkutan',
                Icons.local_shipping_rounded,
                subtitle: 'Pilih kebun untuk menampilkan truk default.',
              ),
              const SizedBox(height: 10),
              if (_kebunId == null)
                _contextState(
                  icon: Icons.local_shipping_outlined,
                  text: 'Pilih kebun untuk menampilkan truk default.',
                )
              else if (_availableTruk.isEmpty)
                _contextState(
                  icon: Icons.no_transfer_outlined,
                  text: 'Belum ada data truk aktif.',
                )
              else
                ..._availableTruk.map((item) => _truckInput(item)),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _transportSummary(),
              ),
              const SizedBox(height: 24),
            ],

            _section(
              'Biaya & Pembayaran',
              Icons.payments_rounded,
              subtitle: 'Pilih kebun untuk melihat tarif dan biaya.',
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<BiayaPanen>>(
              future: _previewBiaya(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (_kebunId == null) {
                  return _contextState(
                    icon: Icons.receipt_long_outlined,
                    text: 'Pilih kebun untuk melihat tarif dan biaya.',
                  );
                }
                if (items.isEmpty) {
                  return _contextState(
                    icon: Icons.receipt_long_outlined,
                    text: 'Tarif biaya belum tersedia untuk transaksi ini.',
                  );
                }
                return Column(children: items.map(_biayaInput).toList());
              },
            ),
            const SizedBox(height: 24),

            _section(
              'Catatan',
              Icons.notes_rounded,
              subtitle: 'Tambahkan keterangan jika diperlukan.',
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _keteranganController,
              maxLines: 4,
              decoration: _decoration(
                context,
                'Keterangan',
                Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 28),

            PanenFormSaveButton(
              isSaving: _saving,
              isEditing: _editing,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    return PanenFormDateTile(
      dateLabel: _formatDate(_tanggal),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _tanggal,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _tanggal = date);
      },
    );
  }

  Widget _responsiveWeightPriceFields(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useTwoColumns = width >= 390;

    if (!useTwoColumns) {
      return Column(
        children: [
          _field(
            _beratController,
            'Berat Bersih',
            'Kg',
            validator: _positive,
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          _field(
            _hargaController,
            'Harga Sawit',
            'Rp/Kg',
            validator: _positive,
            icon: Icons.sell_outlined,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _field(
            _beratController,
            'Berat Bersih',
            'Kg',
            validator: _positive,
            icon: Icons.monitor_weight_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _field(
            _hargaController,
            'Harga Sawit',
            'Rp/Kg',
            validator: _positive,
            icon: Icons.sell_outlined,
          ),
        ),
      ],
    );
  }

  Widget _workerTile(Pekerja item) {
    final colors = Theme.of(context).colorScheme;
    final selected = _selectedPekerja.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        value: selected,
        activeColor: colors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.nama,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          item.status,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        onChanged: (checked) => setState(() {
          if (checked == true) {
            _selectedPekerja.add(item.id!);
          } else {
            _selectedPekerja.remove(item.id);
          }
        }),
      ),
    );
  }

  Widget _contextState({required IconData icon, required String text}) {
    return PanenFormContextCard(icon: icon, text: text);
  }

  Widget _transportSummary() {
    final colors = Theme.of(context).colorScheme;
    final total = _selectedTruk.fold<double>(
      0,
      (sum, id) => sum + _parse(_trukWeightControllers[id]?.text ?? ''),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(Icons.scale_rounded, size: 19, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedTruk.length == 1
                  ? 'Berat angkut mengikuti Berat Bersih Panen.'
                  : 'Total pengangkutan',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_selectedTruk.length > 1)
            Text(
              '${_number(total)} Kg',
              style: TextStyle(
                color: colors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }

  Widget _biayaInput(BiayaPanen biaya) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _paymentControllers.putIfAbsent(
      biaya.jenis,
      TextEditingController.new,
    );
    final title = switch (biaya.jenis) {
      TarifJenis.upahPanen => 'Upah Panen',
      TarifJenis.ongkosTruk => 'Ongkos Truk',
      TarifJenis.biayaMuat => 'Biaya Muat',
    };
    final paid = _parse(controller.text);
    final diff = paid - biaya.totalBiaya;
    final status = diff == 0
        ? 'Lunas'
        : diff > 0
        ? 'Lebih Bayar'
        : 'Kurang Bayar';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Rp ${_number(biaya.totalBiaya)}',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tarif Rp ${_number(biaya.tarifPerKg)}/Kg',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => setState(() {}),
            validator: _nonNegative,
            decoration:
                _decoration(
                  context,
                  'Jumlah Dibayarkan',
                  Icons.payments_outlined,
                ).copyWith(
                  suffixText: 'Rp',
                  suffixIcon: TextButton(
                    onPressed: () {
                      controller.text = _number(biaya.totalBiaya);
                      setState(() {});
                    },
                    child: const Text('Sesuai Total'),
                  ),
                ),
          ),
          const SizedBox(height: 7),
          Text(
            'Selisih: ${diff >= 0 ? '+' : ''}Rp ${_number(diff)}  •  Status: $status',
            style: TextStyle(
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: status == 'Lunas'
                  ? colors.primary
                  : isDark
                  ? const Color(0xFFF1CC75)
                  : Colors.orange.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _truckInput(Truk truk) {
    final colors = Theme.of(context).colorScheme;
    final id = truk.id!;
    final selected = _selectedTruk.contains(id);
    final isDefault = _isDefaultTruk(id);
    final multipleTrucks = _selectedTruk.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: selected,
            activeColor: colors.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 1,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    truk.jenis,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              'Supir: ${truk.namaSupir}',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            onChanged: (checked) => setState(() {
              if (checked == true) {
                _selectedTruk.add(id);
                _trukWeightControllers.putIfAbsent(
                  id,
                  TextEditingController.new,
                );
              } else {
                _selectedTruk.remove(id);
              }
            }),
          ),
          if (selected && multipleTrucks)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _trukWeightControllers[id] == null
                  ? const SizedBox.shrink()
                  : _field(
                      _trukWeightControllers[id]!,
                      'Berat diangkut',
                      'Kg',
                      validator: _positive,
                      onChanged: (_) => setState(() {}),
                      icon: Icons.scale_outlined,
                    ),
            ),
          if (selected && !multipleTrucks)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Berat angkut mengikuti Berat Bersih Panen.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, {String? subtitle}) {
    return PanenFormSectionHeader(title: title, icon: icon, subtitle: subtitle);
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String suffix, {
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    String? helperText,
    IconData icon = Icons.numbers_rounded,
  }) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    validator: validator,
    onChanged: onChanged,
    style: const TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w600,
    ),
    decoration: _decoration(
      context,
      label,
      icon,
    ).copyWith(suffixText: suffix, helperText: helperText),
  );

  String? _positive(String? value) =>
      _parse(value ?? '') > 0 ? null : 'Harus lebih dari 0';

  String? _nonNegative(String? value) =>
      (value ?? '').trim().isEmpty || _parse(value!) >= 0
      ? null
      : 'Tidak valid';
}

class _LokasiTimbangDialog extends StatefulWidget {
  const _LokasiTimbangDialog();

  @override
  State<_LokasiTimbangDialog> createState() => _LokasiTimbangDialogState();
}

class _LokasiTimbangDialogState extends State<_LokasiTimbangDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  WeighbridgeType _jenis = WeighbridgeType.ram;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    Navigator.of(context).pop(
      LokasiTimbang(
        nama: _namaController.text.trim(),
        jenis: _jenis,
        alamat: _alamatController.text.trim().isEmpty
            ? null
            : _alamatController.text.trim(),
        aktif: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Lokasi Timbang'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama lokasi'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama lokasi wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat (opsional)',
                ),
              ),
              DropdownButtonFormField<WeighbridgeType>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis lokasi'),
                items: const [
                  DropdownMenuItem(
                    value: WeighbridgeType.ram,
                    child: Text('RAM'),
                  ),
                  DropdownMenuItem(
                    value: WeighbridgeType.lapangan,
                    child: Text('Lapangan'),
                  ),
                ],
                onChanged: (value) => setState(() => _jenis = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

InputDecoration _decoration(BuildContext context, String label, IconData icon) {
  final colors = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: colors.primary, size: 20),
    filled: true,
    fillColor: colors.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: 0.6),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: 0.6),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
  );
}

double _parse(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
