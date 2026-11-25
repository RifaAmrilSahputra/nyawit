import 'package:flutter/material.dart';

class PerawatanFormHeroCard extends StatelessWidget {
  const PerawatanFormHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF173123), Color(0xFF0E1D15)]
              : [
                  colors.primary,
                  Color.lerp(colors.primary, colors.tertiary, .4)!,
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
            color: colors.primary.withValues(alpha: .12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .12)),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Color(0xFF86EFAC),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat pekerjaan kebun',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Simpan rencana perawatan dengan detail yang jelas.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFD4E3D8),
                    fontSize: 13,
                    height: 1.4,
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

class PerawatanFormSectionCard extends StatelessWidget {
  const PerawatanFormSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: .1),
                  ),
                ),
                child: Icon(icon, size: 19, color: colors.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                    letterSpacing: -.2,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 49),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 17),
          ...children,
        ],
      ),
    );
  }
}

class PerawatanFormFieldCaption extends StatelessWidget {
  const PerawatanFormFieldCaption({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      text,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: .5,
      ),
    );
  }
}

class PerawatanPeriodTile extends StatelessWidget {
  const PerawatanPeriodTile({
    super.key,
    required this.label,
    required this.icon,
    required this.dateLabel,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .48),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 11, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PerawatanTotalCostCard extends StatelessWidget {
  const PerawatanTotalCostCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.primary.withValues(alpha: .16)),
      ),
      child: child,
    );
  }
}

class PerawatanWorkerTile extends StatelessWidget {
  const PerawatanWorkerTile({
    super.key,
    required this.name,
    required this.isSelected,
    required this.isActive,
    required this.isDefault,
    required this.onChanged,
  });

  final String name;
  final bool isSelected;
  final bool isActive;
  final bool isDefault;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? colors.primary.withValues(alpha: .36)
              : colors.outlineVariant.withValues(alpha: .4),
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: colors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isActive ? colors.onSurface : colors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (isDefault)
                _WorkerStatusPill(
                  label: 'Default',
                  color: colors.primary,
                  background: colors.primary.withValues(alpha: .1),
                ),
              _WorkerStatusPill(
                label: isActive ? 'Aktif' : 'Nonaktif',
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                background: isActive
                    ? colors.primary.withValues(alpha: .08)
                    : colors.surfaceContainerLow,
              ),
            ],
          ),
        ),
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, size: 19, color: colors.primary),
        ),
      ),
    );
  }
}

class _WorkerStatusPill extends StatelessWidget {
  const _WorkerStatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
