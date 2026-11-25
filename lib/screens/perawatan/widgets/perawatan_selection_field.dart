import 'package:flutter/material.dart';

class PerawatanSelectionOption<T> {
  const PerawatanSelectionOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T? value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class PerawatanSelectionField<T> extends StatelessWidget {
  const PerawatanSelectionField({
    super.key,
    required this.options,
    required this.value,
    required this.placeholder,
    required this.title,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.isRequired = false,
    this.showLockIcon = false,
  });

  final List<PerawatanSelectionOption<T>> options;
  final T? value;
  final String placeholder;
  final String title;
  final IconData icon;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isRequired;
  final bool showLockIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FormField<T?>(
      key: ValueKey(value),
      initialValue: value,
      validator:
          validator ??
          (selected) => isRequired && selected == null
              ? '$placeholder wajib dipilih'
              : null,
      builder: (field) {
        final selected = _findOption(field.value);
        final hasSelection = selected != null;
        final hasError = field.hasError;
        final borderColor = hasError
            ? colors.error
            : hasSelection
            ? colors.primary.withValues(alpha: 0.48)
            : colors.outlineVariant.withValues(alpha: 0.6);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: hasSelection
                  ? colors.surfaceContainerHigh
                  : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: enabled
                    ? () async {
                        final result = await _showOptions(
                          context,
                          selectedValue: field.value,
                        );
                        if (result == null) return;
                        field.didChange(result.value);
                        onChanged(result.value);
                      }
                    : null,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: hasSelection || hasError ? 1.25 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 19,
                        color: hasSelection
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selected?.label ?? placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasSelection
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: hasSelection
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        showLockIcon
                            ? Icons.lock_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 21,
                        color: enabled
                            ? colors.onSurfaceVariant
                            : colors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  PerawatanSelectionOption<T>? _findOption(T? optionValue) {
    for (final option in options) {
      if (option.value == optionValue) return option;
    }
    return null;
  }

  Future<_SelectionResult<T>?> _showOptions(
    BuildContext context, {
    required T? selectedValue,
  }) {
    final colors = Theme.of(context).colorScheme;

    return showModalBottomSheet<_SelectionResult<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.76,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 20, 13),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(icon, size: 20, color: colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${options.length} pilihan',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
              Flexible(
                child: options.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Tidak ada pilihan tersedia.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
                        itemCount: options.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 54,
                          endIndent: 10,
                          color: colors.outlineVariant.withValues(alpha: 0.35),
                        ),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final selected = option.value == selectedValue;

                          return Material(
                            color: selected
                                ? colors.primary.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.pop(
                                context,
                                _SelectionResult<T>(option.value),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 9,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? colors.primary.withValues(
                                                alpha: 0.14,
                                              )
                                            : colors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        option.icon ?? icon,
                                        size: 19,
                                        color: selected
                                            ? colors.primary
                                            : colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            option.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: selected
                                                  ? colors.primary
                                                  : colors.onSurface,
                                              fontSize: 13.5,
                                              fontWeight: selected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                          if (option.subtitle != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              option.subtitle!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: colors.onSurfaceVariant,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (selected) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionResult<T> {
  const _SelectionResult(this.value);

  final T? value;
}
