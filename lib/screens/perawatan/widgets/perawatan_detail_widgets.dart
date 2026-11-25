part of '../perawatan_detail_page.dart';

const _tabularFigures = [FontFeature.tabularFigures()];

// ============================================================
// HERO CARD
// ============================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.type,
    required this.total,
    required this.paymentStatus,
    required this.statusColor,
    required this.statusBackground,
  });

  final String title;
  final String type;
  final String total;
  final String paymentStatus;
  final Color statusColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [colors.primary, const Color(0xFF144903)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: .22)
              : colors.primary.withValues(alpha: .22),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF86EFAC).withValues(alpha: .08)
                : colors.primary.withValues(alpha: .16),
            blurRadius: 22,
            offset: const Offset(0, 9),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const Spacer(),

              _StatusPill(
                label: paymentStatus,
                foreground: statusColor,
                background: statusBackground,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            type,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: .09)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BIAYA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .70),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    fontFeatures: _tabularFigures,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS PILL
// ============================================================

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 125),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// QUICK SUMMARY
// ============================================================

class _QuickSummary extends StatelessWidget {
  const _QuickSummary({
    required this.duration,
    required this.quantity,
    required this.rate,
  });

  final String duration;
  final String quantity;
  final String rate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryItem(
            icon: Icons.schedule_rounded,
            label: 'DURASI',
            value: duration,
          ),

          const _SummaryDivider(),

          _SummaryItem(
            icon: Icons.inventory_2_outlined,
            label: 'JUMLAH',
            value: quantity,
          ),

          const _SummaryDivider(),

          _SummaryItem(icon: Icons.sell_outlined, label: 'TARIF', value: rate),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY ITEM
// ============================================================

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 19),

            const SizedBox(height: 7),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .45,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFeatures: _tabularFigures,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY DIVIDER
// ============================================================

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: .55),
    );
  }
}

// ============================================================
// ACTIVITY INFO
// ============================================================

class _ActivityInfoSection extends StatelessWidget {
  const _ActivityInfoSection({
    required this.kebun,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.quantity,
    required this.rate,
    required this.note,
  });

  final String kebun;
  final DateTime startDate;
  final DateTime endDate;
  final String duration;
  final String? quantity;
  final String rate;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.assignment_rounded,
            title: 'Informasi kegiatan',
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kebun,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${_formatDateLong(startDate)} — ${_formatDateLong(endDate)}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFeatures: _tabularFigures,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _InfoLine(
            label: 'Periode',
            value:
                '${_formatDateLong(startDate)} — ${_formatDateLong(endDate)}',
          ),

          _InfoLine(label: 'Durasi', value: duration),

          if (quantity != null) _InfoLine(label: 'Jumlah', value: quantity!),

          _InfoLine(label: 'Tarif / satuan', value: rate),

          _InfoLine(label: 'Keterangan', value: note, isLast: true),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: colors.onPrimaryContainer),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFO LINE
// ============================================================

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFeatures: _tabularFigures,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
              fontFeatures: _tabularFigures,
            ),
          ),

          if (!isLast) ...[
            const SizedBox(height: 12),

            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: .55),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// WORK STATUS
// ============================================================

class _WorkStatusSection extends StatelessWidget {
  const _WorkStatusSection({
    required this.status,
    required this.onStart,
    required this.onComplete,
  });

  final StatusKegiatan status;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasAction = onStart != null || onComplete != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.engineering_rounded,
            title: 'Status pengerjaan',
          ),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .55),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: .22),
                        blurRadius: 0,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    status.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasAction) ...[
            const SizedBox(height: 14),

            if (onStart != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    status == StatusKegiatan.rencana
                        ? 'Mulai Pengerjaan'
                        : 'Tandai Pengerjaan',
                  ),
                ),
              ),

            if (onComplete != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Tandai Selesai'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// STATUS HISTORY
// ============================================================

class _StatusHistorySection extends StatelessWidget {
  const _StatusHistorySection({required this.history});

  final List<StatusKegiatanPerawatan> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.history_rounded,
            title: 'Riwayat pengerjaan',
          ),

          const SizedBox(height: 16),

          Column(
            children: List.generate(history.length, (index) {
              final item = history[index];
              final isLast = index == history.length - 1;

              return _TimelineItem(
                title: StatusKegiatanExtension.fromValue(item.status).label,
                date: _formatDateLong(item.tanggal),
                note: item.keterangan,
                isLast: isLast,
                colors: colors,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIMELINE
// ============================================================

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.date,
    required this.note,
    required this.isLast,
    required this.colors,
  });

  final String title;
  final String date;
  final String? note;
  final bool isLast;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final hasNote = note?.trim().isNotEmpty == true;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 4),

                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.only(top: 5),
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    date,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFeatures: _tabularFigures,
                    ),
                  ),

                  if (hasNote) ...[
                    const SizedBox(height: 6),

                    Text(
                      note!.trim(),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT SECTION
// ============================================================

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.total,
    required this.dibayarkan,
    required this.sisa,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.payments,
    required this.onAdd,
  });

  final String total;
  final String dibayarkan;
  final String sisa;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final List<PembayaranPerawatan> payments;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: _SectionHeading(
                  icon: Icons.payments_rounded,
                  title: 'Pembayaran',
                ),
              ),

              _StatusPill(
                label: status,
                foreground: statusColor,
                background: statusBackground,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'SISA PEMBAYARAN',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .75,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            sisa,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: statusColor,
              fontSize: 29,
              height: 1.05,
              fontWeight: FontWeight.w800,
              fontFeatures: _tabularFigures,
            ),
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: .55),
          ),

          const SizedBox(height: 15),

          _PaymentSummaryLine(label: 'Total biaya', value: total),

          const SizedBox(height: 12),

          _PaymentSummaryLine(label: 'Total dibayar', value: dibayarkan),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Pembayaran'),
            ),
          ),

          if (payments.isNotEmpty) ...[
            const SizedBox(height: 22),

            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: .55),
            ),

            const SizedBox(height: 17),

            Text(
              'Riwayat pembayaran',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFeatures: _tabularFigures,
              ),
            ),

            const SizedBox(height: 11),

            ...List.generate(payments.length, (index) {
              final payment = payments[index];

              return _PaymentHistoryItem(
                payment: payment,
                isLast: index == payments.length - 1,
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT SUMMARY LINE
// ============================================================

class _PaymentSummaryLine extends StatelessWidget {
  const _PaymentSummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAYMENT HISTORY
// ============================================================

class _PaymentHistoryItem extends StatelessWidget {
  const _PaymentHistoryItem({required this.payment, required this.isLast});

  final PembayaranPerawatan payment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.payments_outlined,
              size: 17,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currency(payment.jumlah),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFeatures: _tabularFigures,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${payment.jenis} · ${_formatDateLong(payment.tanggal)}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (payment.keterangan?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),

                  Text(
                    payment.keterangan!.trim(),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
