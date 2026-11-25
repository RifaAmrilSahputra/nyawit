import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/screens/kebun/kebun_detail_page.dart';
import 'package:nyawit/screens/panen/panen_page.dart';
import 'package:nyawit/screens/perawatan/perawatan_page.dart';

class KebunItemCard extends StatelessWidget {
  const KebunItemCard({
    super.key,
    required this.kebun,
    required this.onChanged,
  });

  final Kebun kebun;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasDescription = kebun.keterangan?.isNotEmpty ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .55),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: .035),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.forest_rounded,
                      color: colors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kebun.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                kebun.lokasi ?? 'Lokasi belum diisi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
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
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _GardenStat(
                        label: 'Luas',
                        value: kebun.luas == null
                            ? '-'
                            : '${NumberFormat('0.0', 'id_ID').format(kebun.luas)} Ha',
                        numeric: kebun.luas != null,
                      ),
                    ),
                    const _VerticalDivider(),
                    Expanded(
                      child: _GardenStat(
                        label: 'Pohon',
                        value: kebun.jumlahPohon == null
                            ? '-'
                            : NumberFormat(
                                '0',
                                'id_ID',
                              ).format(kebun.jumlahPohon),
                        numeric: kebun.jumlahPohon != null,
                      ),
                    ),
                    const _VerticalDivider(),
                    Expanded(
                      child: _GardenStat(
                        label: 'Status Data',
                        value: hasDescription ? 'Lengkap' : 'Dasar',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _HarvestButton(kebun: kebun)),
                  const SizedBox(width: 10),
                  Expanded(child: _MaintenanceButton(kebun: kebun)),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _openDetails(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    minimumSize: const Size(0, 44),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text(
                    'Lihat detail kebun',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => KebunDetailPage(kebun: kebun)),
    );
    if (changed == true) onChanged();
  }
}

class _HarvestButton extends StatelessWidget {
  const _HarvestButton({required this.kebun});

  final Kebun kebun;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => PanenPage(kebunId: kebun.id, kebunName: kebun.nama),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: colors.primary.withValues(alpha: .07),
        side: BorderSide(color: colors.primary.withValues(alpha: .5)),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      icon: const Icon(Icons.grass_rounded, size: 18),
      label: const Text(
        'Panen',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MaintenanceButton extends StatelessWidget {
  const _MaintenanceButton({required this.kebun});

  final Kebun kebun;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF67D5E8)
        : const Color(0xFF087F95);

    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                PerawatanPage(kebunId: kebun.id, kebunName: kebun.nama),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: accent.withValues(alpha: .08),
        side: BorderSide(color: accent.withValues(alpha: .5)),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      icon: const Icon(Icons.water_drop_rounded, size: 18),
      label: const Text(
        'Perawatan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GardenStat extends StatelessWidget {
  const _GardenStat({
    required this.label,
    required this.value,
    this.numeric = false,
  });

  final String label;
  final String value;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            fontFeatures: numeric ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
