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
import 'package:nyawit/screens/panen/widgets/panen_filter.dart';

const _green = Color(0xFF176B3A);

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
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadKebuns() async {
    final kebuns = await _kebunRepository.getAll();
    if (mounted) setState(() => _kebuns = kebuns);
  }

  Future<void> _refresh() async {
    setState(() => _future = _repository.getAll());
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
      if (kebun.id == id) return kebun.nama;
    }
    return 'Kebun tidak ditemukan';
  }

  Future<void> _openForm([Panen? panen]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PanenFormPageImplementation(
          panen: panen,
          initialKebunId: panen == null ? widget.kebunId : null,
          lockKebun: widget.kebunId != null,
        ),
      ),
    );
    if (changed == true && mounted) await _refresh();
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
    if (confirmed != true || panen.id == null) return;
    await _repository.delete(panen.id!);
    if (mounted) await _refresh();
  }

  Future<void> _openDetail(Panen panen) async {
    if (panen.id == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PanenDetailPage(panenId: panen.id!)),
    );
    if (changed == true && mounted) await _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scopedKebunName = widget.kebunName ?? _kebunName(widget.kebunId ?? 0);
    final isScopedToKebun = widget.kebunId != null;
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
      body: FutureBuilder<List<Panen>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
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
            color: _green,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
              children: [
                _header(
                  panens.length,
                  scopedKebunName: isScopedToKebun ? scopedKebunName : null,
                ),
                const SizedBox(height: 16),
                PanenFilter(
                  searchController: _searchController,
                  kebuns: _kebuns,
                  selectedKebunId: _filterKebunId,
                  selectedDate: _filterDate,
                  isScopedToKebun: isScopedToKebun,
                  scopedKebunName: scopedKebunName,
                  onKebunChanged: (value) =>
                      setState(() => _filterKebunId = value),
                  onDateChanged: (value) => setState(() => _filterDate = value),
                  onDateCleared: () => setState(() => _filterDate = null),
                ),
                const SizedBox(height: 20),
                if (panens.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Center(
                      child: Text(
                        snapshot.data?.isEmpty ?? true
                            ? 'Belum ada transaksi panen.'
                            : 'Tidak ada panen yang sesuai filter.',
                      ),
                    ),
                  )
                else
                  ...panens.map(
                    (panen) => _PanenCard(
                      panen: panen,
                      kebunName: _kebunName(panen.kebunId),
                      onTap: () => _openDetail(panen),
                      onEdit: () => _openForm(panen),
                      onDelete: () => _delete(panen),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(int count, {String? scopedKebunName}) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF176B3A), Color(0xFF23864B)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: _green.withValues(alpha: .16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .10)),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 25),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scopedKebunName ?? 'Panen',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB9E8C8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$count kegiatan panen tercatat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
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
        const SizedBox(width: 10),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _openForm,
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.add_rounded, color: _green, size: 22)],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

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
    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator(color: _green)),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        title: Text(
          _editing ? 'Edit Panen' : 'Tambah Panen',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _section('Informasi Panen', Icons.eco_rounded),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE1E6E1)),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.calendar_today_rounded, color: _green),
              title: const Text('Tanggal'),
              subtitle: Text(_formatDate(_tanggal)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _tanggal,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _tanggal = date);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _kebunId,
              decoration: _decoration(context, 'Kebun', Icons.park_rounded),
              items: _kebuns
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.nama),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Kebun wajib dipilih' : null,
              onChanged: widget.lockKebun
                  ? null
                  : (value) async {
                      if (value == _kebunId) return;
                      setState(() {
                        _kebunId = value;
                        _selectedPekerja = {};
                        _selectedTruk = {};
                        for (final controller
                            in _trukWeightControllers.values) {
                          controller.dispose();
                        }
                        _trukWeightControllers.clear();
                      });
                      await _loadKebunRelations(applyDefaults: true);
                      if (mounted) setState(() {});
                    },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _beratController,
                    'Berat Bersih',
                    'Kg',
                    validator: _positive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _hargaController,
                    'Harga Sawit',
                    'Rp/Kg',
                    validator: _positive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              _sortirController,
              'Sortir (opsional)',
              'Kg',
              validator: _nonNegative,
              helperText: 'Catatan Kg sortir; tidak mengurangi berat bersih.',
            ),
            const SizedBox(height: 24),
            _section('Metode & Lokasi', Icons.local_shipping_rounded),
            const SizedBox(height: 8),
            SegmentedButton<ShippingMethod>(
              segments: const [
                ButtonSegment(
                  value: ShippingMethod.antar,
                  label: Text('Antar'),
                  icon: Icon(Icons.local_shipping_rounded),
                ),
                ButtonSegment(
                  value: ShippingMethod.lapangan,
                  label: Text('Lapangan'),
                  icon: Icon(Icons.landscape_rounded),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (value) =>
                  setState(() => _method = value.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              key: ValueKey(_lokasiId),
              initialValue: _lokasiId,
              decoration: _decoration(
                context,
                'Lokasi Timbang',
                Icons.scale_rounded,
              ),
              hint: const Text('Pilih lokasi timbang'),
              items: _lokasi
                  .where((item) => item.aktif || item.id == _lokasiId)
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.nama),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Lokasi timbang wajib dipilih' : null,
              onChanged: (value) => setState(() => _lokasiId = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addLokasiTimbang,
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text(
                  _lokasi.isEmpty
                      ? 'Tambah lokasi timbang terlebih dahulu'
                      : 'Tambah lokasi timbang baru',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _section('Pekerja', Icons.engineering_rounded),
            const SizedBox(height: 6),
            if (_kebunId == null)
              _hint('Pilih kebun untuk memuat pekerja aktif.')
            else if (_availablePekerja.isEmpty)
              _hint('Tidak ada pekerja aktif yang terhubung ke kebun ini.')
            else
              ..._availablePekerja.map(
                (item) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selectedPekerja.contains(item.id),
                  title: Text(item.nama),
                  subtitle: Text(item.status),
                  activeColor: _green,
                  onChanged: (checked) => setState(() {
                    if (checked == true) {
                      _selectedPekerja.add(item.id!);
                    } else {
                      _selectedPekerja.remove(item.id);
                    }
                  }),
                ),
              ),
            if (_method == ShippingMethod.antar) ...[
              const SizedBox(height: 18),
              _section('Pengangkutan', Icons.local_shipping_rounded),
              const SizedBox(height: 4),
              if (_kebunId == null)
                _hint('Pilih kebun untuk menampilkan truk default.')
              else if (_availableTruk.isEmpty)
                _hint('Belum ada data truk aktif.')
              else
                ..._availableTruk.map((item) => _truckInput(item)),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _selectedTruk.length == 1
                      ? 'Satu truk mengangkut seluruh Berat Bersih Panen.'
                      : 'Total pengangkutan: ${_number(_selectedTruk.fold<double>(0, (sum, id) => sum + _parse(_trukWeightControllers[id]?.text ?? '')))} Kg',
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _section('Biaya & Pembayaran', Icons.payments_rounded),
            const SizedBox(height: 8),
            FutureBuilder<List<BiayaPanen>>(
              future: _previewBiaya(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (_kebunId == null) {
                  return _hint('Pilih kebun untuk melihat tarif dan biaya.');
                }
                return Column(children: items.map(_biayaInput).toList());
              },
            ),
            const SizedBox(height: 24),
            _section('Catatan', Icons.notes_rounded),
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
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_editing ? 'Simpan Perubahan' : 'Simpan Panen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _biayaInput(BiayaPanen biaya) {
    final controller = _paymentControllers.putIfAbsent(
      biaya.jenis,
      TextEditingController.new,
    );
    final title = switch (biaya.jenis) {
      TarifJenis.upahPanen => 'Biaya Panen',
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
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Tarif: Rp ${_number(biaya.tarifPerKg)}/Kg  •  Total: Rp ${_number(biaya.totalBiaya)}',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
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
                    Icons.payments_rounded,
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
            const SizedBox(height: 6),
            Text(
              'Selisih: ${diff >= 0 ? '+' : ''}Rp ${_number(diff)}  •  Status: $status',
              style: TextStyle(
                fontSize: 12,
                color: status == 'Lunas' ? _green : Colors.orange.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _truckInput(Truk truk) {
    final id = truk.id!;
    final selected = _selectedTruk.contains(id);
    final isDefault = _isDefaultTruk(id);
    final multipleTrucks = _selectedTruk.length > 1;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE1E6E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            CheckboxListTile(
              value: selected,
              activeColor: _green,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Row(
                children: [
                  Flexible(child: Text(truk.jenis)),
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F3E9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Default kebun',
                        style: TextStyle(
                          color: _green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text('Supir: ${truk.namaSupir}'),
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: _field(
                  _trukWeightControllers[id]!,
                  'Berat diangkut',
                  'Kg',
                  validator: _positive,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            if (selected && !multipleTrucks)
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Berat angkut mengikuti Berat Bersih Panen.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F3E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: _green),
      ),
      const SizedBox(width: 9),
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ],
  );
  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    ),
  );
  Widget _field(
    TextEditingController controller,
    String label,
    String suffix, {
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    String? helperText,
  }) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    validator: validator,
    onChanged: onChanged,
    decoration: _decoration(
      context,
      label,
      Icons.numbers_rounded,
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

class _PanenCard extends StatelessWidget {
  const _PanenCard({
    required this.panen,
    required this.kebunName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final Panen panen;
  final String kebunName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAntar = panen.shippingMethod == ShippingMethod.antar;
    final nilaiPanen = panen.beratBersih * panen.hargaSawit;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: colors.primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kebunName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatDate(panen.tanggal),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.outlineVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Icon(
                              isAntar
                                  ? Icons.local_shipping_rounded
                                  : Icons.landscape_rounded,
                              size: 13,
                              color: _green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAntar ? 'Antar' : 'Lapangan',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Menu panen',
                    padding: EdgeInsets.zero,
                    onSelected: (value) =>
                        value == 'edit' ? onEdit() : onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_rounded, size: 20),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                          title: Text('Hapus'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _meta(
                        'Berat bersih',
                        '${_number(panen.beratBersih)} Kg',
                      ),
                    ),
                    _verticalDivider(context),
                    Expanded(
                      child: _meta(
                        'Harga sawit',
                        'Rp ${_number(panen.hargaSawit)}',
                      ),
                    ),
                    _verticalDivider(context),
                    Expanded(
                      child: _meta('Nilai panen', 'Rp ${_number(nilaiPanen)}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider(BuildContext context) => Container(
    width: 1,
    height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Theme.of(context).colorScheme.outlineVariant,
  );
  Widget _meta(String label, String value) => Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

InputDecoration _decoration(BuildContext context, String label, IconData icon) {
  final colors = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: _green, size: 20),
    filled: true,
    fillColor: colors.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _green, width: 1.5),
    ),
  );
}

double _parse(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
