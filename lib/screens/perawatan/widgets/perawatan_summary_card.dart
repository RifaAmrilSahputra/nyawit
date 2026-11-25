import 'package:flutter/material.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_formatters.dart';

// SUMMARY CARD
// ============================================================

class PerawatanSummaryCard extends StatelessWidget {
  const PerawatanSummaryCard({
    super.key,
    required this.count,
    required this.totalBiaya,
    required this.totalDibayarkan,
    required this.onAdd,
  });

  final int count;
  final double totalBiaya;
  final double totalDibayarkan;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final remaining = totalBiaya - totalDibayarkan;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [
                  colors.primary,
                  Color.lerp(colors.primary, colors.tertiary, .42)!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: .24)
              : colors.primary.withValues(alpha: .16),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? .12 : .16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.bloodtype_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Perawatan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count kegiatan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Material(
                    color: isDark ? const Color(0xFFC7F0D5) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.add_rounded,
                          color: isDark
                              ? const Color(0xFF173123)
                              : colors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryValue(
                        label: 'Total biaya',
                        value: formatPerawatanCurrency(totalBiaya),
                      ),
                    ),

                    const _SummaryDivider(),

                    Expanded(
                      child: _SummaryValue(
                        label: 'Dibayarkan',
                        value: formatPerawatanCurrency(totalDibayarkan),
                      ),
                    ),

                    const _SummaryDivider(),

                    Expanded(
                      child: _SummaryValue(
                        label: 'Sisa',
                        value: formatPerawatanCurrency(
                          remaining < 0 ? 0 : remaining,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
