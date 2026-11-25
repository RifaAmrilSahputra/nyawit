import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/tarif_perawatan.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_selection_field.dart';

// SEARCH FIELD
// ============================================================

class PerawatanSearchField extends StatelessWidget {
  const PerawatanSearchField({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        controller: TextEditingController(text: query)
          ..selection = TextSelection.collapsed(offset: query.length),
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kegiatan perawatan...',
          hintStyle: TextStyle(
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 21,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.onSurfaceVariant,
                    size: 19,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER ROW
// ============================================================

class PerawatanFilterRow extends StatelessWidget {
  const PerawatanFilterRow({
    super.key,
    required this.selectedKebunId,
    required this.selectedJenis,
    required this.kebuns,
    required this.onKebunChanged,
    required this.onJenisChanged,
  });

  final int? selectedKebunId;
  final JenisPerawatan? selectedJenis;
  final List<Kebun> kebuns;

  final ValueChanged<int?> onKebunChanged;
  final ValueChanged<JenisPerawatan?> onJenisChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KebunDropdown(
            selectedKebunId: selectedKebunId,
            kebuns: kebuns,
            onChanged: onKebunChanged,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _JenisDropdown(
            selectedJenis: selectedJenis,
            onChanged: onJenisChanged,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// KEBUN DROPDOWN
// ============================================================

class _KebunDropdown extends StatelessWidget {
  const _KebunDropdown({
    required this.selectedKebunId,
    required this.kebuns,
    required this.onChanged,
  });

  final int? selectedKebunId;
  final List<Kebun> kebuns;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PerawatanSelectionField<int>(
      options: [
        const PerawatanSelectionOption<int>(
          value: null,
          label: 'Semua Kebun',
          icon: Icons.forest_outlined,
        ),
        ...kebuns.map(
          (kebun) => PerawatanSelectionOption<int>(
            value: kebun.id,
            label: kebun.nama,
            subtitle: kebun.lokasi,
            icon: Icons.forest_rounded,
          ),
        ),
      ],
      value: selectedKebunId,
      placeholder: 'Kebun',
      title: 'Pilih Kebun',
      icon: Icons.park_rounded,
      onChanged: onChanged,
    );
  }
}

// ============================================================
// JENIS DROPDOWN
// ============================================================

class _JenisDropdown extends StatelessWidget {
  const _JenisDropdown({required this.selectedJenis, required this.onChanged});

  final JenisPerawatan? selectedJenis;
  final ValueChanged<JenisPerawatan?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PerawatanSelectionField<JenisPerawatan>(
      options: [
        const PerawatanSelectionOption<JenisPerawatan>(
          value: null,
          label: 'Semua Jenis',
          icon: Icons.category_outlined,
        ),
        ...JenisPerawatan.values.map(
          (jenis) => PerawatanSelectionOption<JenisPerawatan>(
            value: jenis,
            label: jenis.label,
            icon: Icons.category_rounded,
          ),
        ),
      ],
      value: selectedJenis,
      placeholder: 'Jenis',
      title: 'Pilih Jenis',
      icon: Icons.category_rounded,
      onChanged: onChanged,
    );
  }
}

// ============================================================
