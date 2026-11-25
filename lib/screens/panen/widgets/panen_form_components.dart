import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/lokasi_timbang.dart';

class PanenFormSectionHeader extends StatelessWidget {
  const PanenFormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PanenFormDateTile extends StatelessWidget {
  const PanenFormDateTile({
    super.key,
    required this.dateLabel,
    required this.onTap,
  });

  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: colors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TANGGAL',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class PanenFormContextCard extends StatelessWidget {
  const PanenFormContextCard({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: colors.onSurfaceVariant),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanenFormSaveButton extends StatelessWidget {
  const PanenFormSaveButton({
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
      child: FilledButton.icon(
        onPressed: isSaving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        icon: isSaving
            ? SizedBox.square(
                dimension: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          isEditing ? 'Simpan Perubahan' : 'Simpan Panen',
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class PanenGardenSelector extends StatelessWidget {
  const PanenGardenSelector({
    super.key,
    required this.kebuns,
    required this.selectedKebunId,
    required this.onChanged,
    this.enabled = true,
    this.showAllOption = false,
    this.isRequired = true,
    this.allOptionLabel = 'Semua kebun',
    this.fallbackKebunName,
  });

  final List<Kebun> kebuns;
  final int? selectedKebunId;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  final bool showAllOption;
  final bool isRequired;
  final String allOptionLabel;
  final String? fallbackKebunName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FormField<int>(
      key: ValueKey(selectedKebunId),
      initialValue: selectedKebunId,
      validator: (value) =>
          isRequired && value == null ? 'Kebun wajib dipilih' : null,
      builder: (field) {
        final selected = _findKebun(field.value);
        final hasError = field.hasError;
        final hasSelection = selected != null || showAllOption;
        final borderColor = hasError
            ? colors.error
            : hasSelection
            ? colors.primary.withValues(alpha: 0.48)
            : colors.outlineVariant.withValues(alpha: 0.65);

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
                        final selection = await _showGardenPicker(
                          context,
                          selectedId: field.value,
                        );
                        if (selection == null) return;
                        field.didChange(selection.kebunId);
                        onChanged(selection.kebunId);
                      }
                    : null,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
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
                        Icons.park_rounded,
                        size: 21,
                        color: hasSelection
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selected?.nama ??
                              (showAllOption && field.value == null
                                  ? allOptionLabel
                                  : fallbackKebunName ?? 'Pilih kebun'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: !hasSelection
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: !hasSelection
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 23,
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

  Kebun? _findKebun(int? id) {
    for (final item in kebuns) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<_PanenGardenSelection?> _showGardenPicker(
    BuildContext context, {
    required int? selectedId,
  }) {
    final colors = Theme.of(context).colorScheme;
    final hasFallback =
        fallbackKebunName != null &&
        !kebuns.any((item) => item.id == selectedId);
    final itemCount =
        kebuns.length + (hasFallback ? 1 : 0) + (showAllOption ? 1 : 0);

    return showModalBottomSheet<_PanenGardenSelection>(
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
              _PanenPickerHandle(color: colors.outlineVariant),
              _PanenPickerHeader(
                icon: Icons.park_rounded,
                title: 'Pilih Kebun',
                count: showAllOption
                    ? '$itemCount pilihan'
                    : '${kebuns.length} kebun',
              ),
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
              Flexible(
                child: itemCount == 0
                    ? _PanenPickerEmptyState(
                        message: 'Belum ada data kebun.',
                        color: colors.onSurfaceVariant,
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: itemCount,
                        separatorBuilder: (context, index) =>
                            _PanenPickerDivider(colors: colors),
                        itemBuilder: (context, index) {
                          if (showAllOption && index == 0) {
                            return _PanenPickerItem(
                              title: allOptionLabel,
                              icon: Icons.forest_outlined,
                              selected: selectedId == null,
                              onTap: () => Navigator.pop(
                                context,
                                const _PanenGardenSelection(null),
                              ),
                            );
                          }

                          final gardenIndex = index - (showAllOption ? 1 : 0);
                          if (gardenIndex < kebuns.length) {
                            final item = kebuns[gardenIndex];
                            return _PanenPickerItem(
                              title: item.nama,
                              icon: Icons.forest_rounded,
                              selected: item.id == selectedId,
                              onTap: () => Navigator.pop(
                                context,
                                _PanenGardenSelection(item.id),
                              ),
                            );
                          }

                          return _PanenPickerItem(
                            title: fallbackKebunName!,
                            icon: Icons.forest_rounded,
                            selected: selectedId != null,
                            onTap: () => Navigator.pop(
                              context,
                              _PanenGardenSelection(selectedId),
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

class _PanenGardenSelection {
  const _PanenGardenSelection(this.kebunId);

  final int? kebunId;
}

class PanenWeighbridgeSelector extends StatelessWidget {
  const PanenWeighbridgeSelector({
    super.key,
    required this.lokasi,
    required this.selectedLokasiId,
    required this.onChanged,
  });

  final List<LokasiTimbang> lokasi;
  final int? selectedLokasiId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FormField<int>(
      key: ValueKey(selectedLokasiId),
      initialValue: selectedLokasiId,
      validator: (value) =>
          value == null ? 'Lokasi timbang wajib dipilih' : null,
      builder: (field) {
        final selected = _findLokasi(field.value);
        final hasError = field.hasError;
        final borderColor = hasError
            ? colors.error
            : selected != null
            ? colors.primary.withValues(alpha: 0.48)
            : colors.outlineVariant.withValues(alpha: 0.65);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: selected == null
                  ? colors.surfaceContainerLow
                  : colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final id = await _showWeighbridgePicker(
                    context,
                    selectedId: field.value,
                  );
                  if (id == null) return;
                  field.didChange(id);
                  onChanged(id);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: selected != null || hasError ? 1.25 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.scale_rounded,
                        size: 21,
                        color: selected == null
                            ? colors.onSurfaceVariant
                            : colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selected?.nama ?? 'Pilih lokasi timbang',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: selected == null
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: selected == null
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 23,
                        color: colors.onSurfaceVariant,
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

  LokasiTimbang? _findLokasi(int? id) {
    for (final item in lokasi) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<int?> _showWeighbridgePicker(
    BuildContext context, {
    required int? selectedId,
  }) {
    final colors = Theme.of(context).colorScheme;
    final available = lokasi
        .where((item) => item.aktif || item.id == selectedId)
        .toList();

    return showModalBottomSheet<int>(
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
              _PanenPickerHandle(color: colors.outlineVariant),
              _PanenPickerHeader(
                icon: Icons.scale_rounded,
                title: 'Pilih Lokasi Timbang',
                count: '${available.length} lokasi',
              ),
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
              Flexible(
                child: available.isEmpty
                    ? _PanenPickerEmptyState(
                        message: 'Belum ada lokasi timbang aktif.',
                        color: colors.onSurfaceVariant,
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: available.length,
                        separatorBuilder: (context, index) =>
                            _PanenPickerDivider(colors: colors),
                        itemBuilder: (context, index) {
                          final item = available[index];
                          final type = switch (item.jenis) {
                            WeighbridgeType.ram => 'RAM',
                            WeighbridgeType.lapangan => 'Lapangan',
                          };
                          final subtitle = [
                            type,
                            if (item.alamat?.trim().isNotEmpty ?? false)
                              item.alamat!.trim(),
                          ].join(' • ');

                          return _PanenPickerItem(
                            title: item.nama,
                            subtitle: subtitle,
                            icon: Icons.scale_outlined,
                            selected: item.id == selectedId,
                            onTap: () => Navigator.pop(context, item.id),
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

class _PanenPickerHandle extends StatelessWidget {
  const _PanenPickerHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _PanenPickerHeader extends StatelessWidget {
  const _PanenPickerHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanenPickerDivider extends StatelessWidget {
  const _PanenPickerDivider({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      endIndent: 12,
      color: colors.outlineVariant.withValues(alpha: 0.35),
    );
  }
}

class _PanenPickerEmptyState extends StatelessWidget {
  const _PanenPickerEmptyState({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}

class _PanenPickerItem extends StatelessWidget {
  const _PanenPickerItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.14)
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? colors.primary : colors.onSurface,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.5,
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
                  size: 19,
                  color: colors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
