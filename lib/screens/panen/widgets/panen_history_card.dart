import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyawit/models/panen.dart';

class PanenHistoryCard extends StatelessWidget {
  const PanenHistoryCard({
    super.key,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 17, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanenCardHeader(
                  kebunName: kebunName,
                  tanggal: panen.tanggal,
                  isAntar: isAntar,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),

                const SizedBox(height: 18),

                _PanenMetrics(
                  beratBersih: panen.beratBersih,
                  hargaSawit: panen.hargaSawit,
                  nilaiPanen: nilaiPanen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanenCardHeader extends StatelessWidget {
  const _PanenCardHeader({
    required this.kebunName,
    required this.tanggal,
    required this.isAntar,
    required this.onEdit,
    required this.onDelete,
  });

  final String kebunName;
  final DateTime tanggal;
  final bool isAntar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: colors.secondaryContainer.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.eco_rounded, color: colors.primary, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kebunName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.15,
                ),
              ),

              const SizedBox(height: 7),

              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 7,
                runSpacing: 4,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: colors.onSurfaceVariant,
                  ),

                  Text(
                    _formatPanenDate(tanggal),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),

                  Icon(
                    isAntar
                        ? Icons.local_shipping_rounded
                        : Icons.landscape_rounded,
                    size: 13,
                    color: const Color(0xFF42A765),
                  ),

                  Text(
                    isAntar ? 'Antar' : 'Lapangan',
                    style: TextStyle(
                      color: const Color(0xFF42A765),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        _PanenMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }
}

class _PanenMenu extends StatelessWidget {
  const _PanenMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Menu panen',
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_horiz_rounded,
        color: colors.onSurfaceVariant,
        size: 22,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else {
          onDelete();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_rounded, size: 20),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Colors.red,
            ),
            title: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}

class _PanenMetrics extends StatelessWidget {
  const _PanenMetrics({
    required this.beratBersih,
    required this.hargaSawit,
    required this.nilaiPanen,
  });

  final num beratBersih;
  final num hargaSawit;
  final num nilaiPanen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'BERAT BERSIH',
                  value: '${_formatPanenValue(beratBersih)} Kg',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _MetricItem(
                  label: 'HARGA SAWIT',
                  value: 'Rp ${_formatRupiah(hargaSawit)}',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.primary.withValues(alpha: .2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NILAI PANEN',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Rp ${_formatRupiah(nilaiPanen)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.35,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: colors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: .35,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: .65),
    );
  }
}

class PanenEmptyState extends StatelessWidget {
  const PanenEmptyState({
    super.key,
    required this.hasData,
    required this.onAdd,
  });

  final bool hasData;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 46, 18, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: .55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasData ? Icons.search_off_rounded : Icons.eco_outlined,
              color: colors.primary,
              size: 29,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            hasData ? 'Tidak menemukan panen' : 'Belum ada panen',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            hasData
                ? 'Coba gunakan nama kebun yang berbeda.'
                : 'Belum ada data panen yang tercatat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          if (!hasData) ...[
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Tambah Panen'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatPanenValue(num value) =>
    NumberFormat('#,##0.##', 'id_ID').format(value);

String _formatRupiah(num value) => NumberFormat('#,##0', 'id_ID').format(value);

String _formatPanenDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';
