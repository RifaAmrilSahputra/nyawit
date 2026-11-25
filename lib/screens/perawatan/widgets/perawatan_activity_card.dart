import 'package:flutter/material.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_formatters.dart';

// PERAWATAN CARD
// ============================================================

class PerawatanActivityCard extends StatelessWidget {
  const PerawatanActivityCard({
    super.key,
    required this.item,
    required this.kebunName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final KegiatanPerawatan item;
  final String kebunName;
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
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),

            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.04),
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
                                style: TextStyle(
                                  color: colors.onSurface,
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
                                kebunName,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .45),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CardInfo(
                        icon: Icons.calendar_month_rounded,
                        label: 'Tanggal',
                        value: formatPerawatanDateRange(
                          item.tanggalMulai,
                          item.tanggalSelesai,
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: colors.outlineVariant,
                    ),

                    Expanded(
                      child: _CardInfo(
                        icon: Icons.payments_rounded,
                        label: 'Biaya',
                        value: formatPerawatanCurrency(item.totalBiaya),
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

                  const SizedBox(width: 8),

                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
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
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Menu',

      icon: Icon(
        Icons.more_horiz_rounded,
        size: 21,
        color: colors.onSurfaceVariant,
      ),

      padding: EdgeInsets.zero,

      color: colors.surfaceContainer,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },

      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 10),
              Text('Edit', style: TextStyle(color: colors.onSurface)),
            ],
          ),
        ),

        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: colors.error),
              const SizedBox(width: 10),
              Text('Hapus', style: TextStyle(color: colors.error)),
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
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
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
      constraints: const BoxConstraints(maxWidth: 165),

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
              maxLines: 2,
              softWrap: true,
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
  final isDark = colors.brightness == Brightness.dark;

  switch (status) {
    case 'lunas':
      return isDark ? const Color(0xFF66BB78) : const Color(0xFF2E7D32);

    case 'kurang_bayar':
      return isDark ? const Color(0xFFE5A93D) : const Color(0xFFD98E04);

    case 'lebih_bayar':
      return isDark ? const Color(0xFF69A5D8) : const Color(0xFF3D78B5);

    default:
      return isDark ? const Color(0xFFEF6B6B) : const Color(0xFFC84242);
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
