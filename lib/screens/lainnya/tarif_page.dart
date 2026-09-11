import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/tarif.dart';
import 'package:nyawit/repositories/kebun_repository.dart';
import 'package:nyawit/repositories/tarif_repository.dart';

class TarifPage extends StatefulWidget {
  const TarifPage({super.key});

  @override
  State<TarifPage> createState() => _TarifPageState();
}

class _TarifPageState extends State<TarifPage> {
  final TarifRepository _tarifRepository = TarifRepository();
  final KebunRepository _kebunRepository = KebunRepository();

  List<Kebun> _kebuns = [];
  List<Tarif> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await Future.wait([
        _tarifRepository.getAll(),
        _kebunRepository.getAll(),
      ]);

      if (!mounted) return;

      setState(() {
        _items = result[0] as List<Tarif>;
        _kebuns = result[1] as List<Kebun>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tarif: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Tarif? _find(TarifJenis jenis, [int? kebunId]) {
    for (final item in _items) {
      if (item.jenis == jenis && item.kebunId == kebunId) {
        return item;
      }
    }

    return null;
  }

  Future<void> _editTarif({
    required TarifJenis jenis,
    int? kebunId,
    required String title,
    required String subtitle,
    required IconData icon,
  }) async {
    final current = _find(jenis, kebunId);

    final controller = TextEditingController(
      text: current == null ? '' : _number(current.nilaiPerKg),
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditTarifSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          controller: controller,
        );
      },
    );

    if (result == true) {
      final text = controller.text.trim().replaceAll(',', '.');
      final value = double.tryParse(text);

      if (value == null || value < 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Masukkan tarif yang valid'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        controller.dispose();
        return;
      }

      final now = DateTime.now();

      await _tarifRepository.save(
        Tarif(
          id: current?.id,
          jenis: jenis,
          kebunId: kebunId,
          nilaiPerKg: value,
          createdAt: current?.createdAt ?? now,
          updatedAt: now,
        ),
      );

      await _load();
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Tarif',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                children: [
                  // =========================
                  // INFO
                  // =========================
                  Text(
                    'Pengaturan tarif',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Atur biaya yang digunakan dalam perhitungan panen dan operasional.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================
                  // TARIF GLOBAL
                  // =========================
                  _sectionHeader(context, 'TARIF GLOBAL'),

                  const SizedBox(height: 8),

                  _settingGroup(
                    context,
                    children: [
                      _settingTile(
                        icon: Icons.local_shipping_outlined,
                        iconColor: const Color(0xFF3978B8),
                        iconBackground: const Color(0xFFEAF2FA),
                        title: 'Ongkos Truk',
                        subtitle: 'Biaya pengangkutan TBS',
                        value: _find(TarifJenis.ongkosTruk)?.nilaiPerKg ?? 0,
                        onTap: () {
                          _editTarif(
                            jenis: TarifJenis.ongkosTruk,
                            title: 'Ongkos Truk',
                            subtitle: 'Biaya pengangkutan TBS',
                            icon: Icons.local_shipping_outlined,
                          );
                        },
                      ),
                      _divider(context),
                      _settingTile(
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFFB47716),
                        iconBackground: const Color(0xFFFBF3E2),
                        title: 'Biaya Muat',
                        subtitle: 'Biaya pemuatan TBS',
                        value: _find(TarifJenis.biayaMuat)?.nilaiPerKg ?? 0,
                        onTap: () {
                          _editTarif(
                            jenis: TarifJenis.biayaMuat,
                            title: 'Biaya Muat',
                            subtitle: 'Biaya pemuatan TBS',
                            icon: Icons.inventory_2_outlined,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // TARIF PANEN
                  // =========================
                  _sectionHeader(context, 'UPAH PANEN PER KEBUN'),

                  const SizedBox(height: 8),

                  if (_kebuns.isEmpty)
                    _emptyState(context)
                  else
                    _settingGroup(
                      context,
                      children: [
                        for (int i = 0; i < _kebuns.length; i++) ...[
                          _settingTile(
                            icon: Icons.agriculture_outlined,
                            iconColor: const Color(0xFF25834A),
                            iconBackground: const Color(0xFFE9F6ED),
                            title: _kebuns[i].nama,
                            subtitle: 'Upah panen',
                            value:
                                _find(
                                  TarifJenis.upahPanen,
                                  _kebuns[i].id,
                                )?.nilaiPerKg ??
                                0,
                            onTap: () {
                              _editTarif(
                                jenis: TarifJenis.upahPanen,
                                kebunId: _kebuns[i].id,
                                title: _kebuns[i].nama,
                                subtitle: 'Upah panen',
                                icon: Icons.agriculture_outlined,
                              );
                            },
                          ),
                          if (i < _kebuns.length - 1) _divider(context),
                        ],
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _settingGroup(BuildContext context, {required List<Widget> children}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required double value,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // ICON
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 21, color: iconColor),
              ),

              const SizedBox(width: 13),

              // TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // VALUE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_number(value)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF176B3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '/ Kg',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9AA29C)),
                  ),
                ],
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFFB2B9B4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 69,
      endIndent: 14,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.agriculture_outlined,
              color: Color(0xFF6F7C72),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada kebun',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Tambahkan kebun terlebih dahulu untuk mengatur upah panen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A928C),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// EDIT TARIF BOTTOM SHEET
// ======================================================

class _EditTarifSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final TextEditingController controller;

  const _EditTarifSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HANDLE
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // HEADER
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF176B3A), size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Tarif per Kg',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // INPUT
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              suffixText: '/ Kg',
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF176B3A),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF176B3A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Simpan Tarif',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FORMAT ANGKA
// ======================================================

String _number(num value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}
