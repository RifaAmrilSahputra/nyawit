import 'package:flutter/material.dart';

class PanenHeroCard extends StatelessWidget {
  const PanenHeroCard({
    super.key,
    required this.count,
    required this.onAdd,
    this.scopedKebunName,
  });

  final int count;
  final String? scopedKebunName;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [
                  colors.primary,
                  Color.lerp(colors.primary, colors.tertiary, .42)!,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: .24)
              : colors.primary.withValues(alpha: .16),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? .12 : .16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .10)),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  scopedKebunName ?? 'Panen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.25,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF86EFAC),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Flexible(
                      child: Text(
                        '$count kegiatan panen tercatat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .70),
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

          _HeroAddButton(onPressed: onAdd),
        ],
      ),
    );
  }
}

class _HeroAddButton extends StatelessWidget {
  const _HeroAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFFC7F0D5) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.add_rounded,
            color: isDark ? const Color(0xFF173123) : colors.primary,
            size: 25,
          ),
        ),
      ),
    );
  }
}
