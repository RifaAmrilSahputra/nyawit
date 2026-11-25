import 'package:flutter/material.dart';

class KebunFormSectionHeader extends StatelessWidget {
  const KebunFormSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B3A2A) : colors.secondaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 21,
            color: isDark ? const Color(0xFF86EFAC) : colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KebunFormInput extends StatelessWidget {
  const KebunFormInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final ColorScheme colors;
  final String? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        fontFeatures: keyboardType == null
            ? null
            : const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(icon, size: 21),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          minHeight: 50,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
        labelStyle: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        hintStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.onSurfaceVariant.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        prefixIconColor: colors.primary,
        border: _border(colors, 0.55),
        enabledBorder: _border(colors, 0.55),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(17)),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  static OutlineInputBorder _border(ColorScheme colors, double alpha) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: alpha),
      ),
    );
  }
}

class KebunFormHeroCard extends StatelessWidget {
  const KebunFormHeroCard({super.key, required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
            color: colors.primary.withValues(alpha: isDark ? .12 : .12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.forest_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Perbarui kebun' : 'Kebun baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isEditing
                      ? 'Periksa data sebelum menyimpan perubahan.'
                      : 'Tambahkan kebun untuk mulai mengelola data.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 12.5,
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

class KebunFormSaveButton extends StatelessWidget {
  const KebunFormSaveButton({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onPressed,
  });

  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isSaving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: .55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSaving
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('button'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 22),
                    const SizedBox(width: 9),
                    Text(
                      isEditing ? 'Simpan Perubahan' : 'Simpan Kebun',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
