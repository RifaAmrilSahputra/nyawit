import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';

class KebunDetailPage extends StatelessWidget {
  const KebunDetailPage({super.key, required this.kebun});

  final Kebun kebun;

  Future<void> _editKebun(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => KebunFormPage(kebun: kebun)),
    );

    if (changed == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (kebun.keterangan?.isNotEmpty ?? false) ? 'Aktif' : 'Siap';

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Kebun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _editKebun(context),
              tooltip: 'Edit kebun',
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                minimumSize: const Size(40, 40),
              ),
              icon: const Icon(Icons.edit_rounded, size: 19),
            ),
          ),
        ],
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          _KebunHeader(kebun: kebun, status: status),

          const SizedBox(height: 30),

          _SectionLabel(
            icon: Icons.info_outline_rounded,
            title: 'Informasi kebun',
          ),

          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              _InfoTile(
                icon: Icons.park_outlined,
                label: 'Nama kebun',
                value: kebun.nama,
              ),
              _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: kebun.lokasi ?? 'Belum diisi',
              ),
              _InfoTile(
                icon: Icons.straighten_outlined,
                label: 'Luas',
                value: kebun.luas == null ? 'Belum diisi' : '${kebun.luas} Ha',
              ),
              _InfoTile(
                icon: Icons.forest_outlined,
                label: 'Jumlah pohon',
                value: kebun.jumlahPohon == null
                    ? 'Belum diisi'
                    : '${kebun.jumlahPohon} pohon',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.notes_outlined, title: 'Catatan'),

          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              _InfoTile(
                icon: Icons.notes_outlined,
                label: 'Keterangan',
                value: kebun.keterangan ?? 'Belum ada keterangan',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _SectionLabel(icon: Icons.history_rounded, title: 'Informasi data'),

          const SizedBox(height: 8),

          _InfoGroup(
            children: [
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Dibuat',
                value: _formatDate(kebun.createdAt),
              ),
              _InfoTile(
                icon: Icons.update_outlined,
                label: 'Diperbarui',
                value: _formatDate(kebun.updatedAt),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class _KebunHeader extends StatelessWidget {
  const _KebunHeader({required this.kebun, required this.status});

  final Kebun kebun;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.forest_rounded, size: 27, color: colors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kebun.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                    letterSpacing: -0.3,
                  ),
                ),

                if (kebun.lokasi?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colors.onPrimaryContainer.withValues(
                          alpha: 0.65,
                        ),
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          kebun.lokasi!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onPrimaryContainer.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 9),

                _KebunStatusBadge(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KebunStatusBadge extends StatelessWidget {
  const _KebunStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isActive = status == 'Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? colors.surface : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: colors.primary),

        const SizedBox(width: 8),

        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: colors.onSurfaceVariant),

              const SizedBox(width: 11),

              SizedBox(
                width: 94,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 43,
            endIndent: 14,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
