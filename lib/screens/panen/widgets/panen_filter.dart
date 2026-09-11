import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';

const panenGreen = Color(0xFF176B3A);

class PanenFilter extends StatelessWidget {
  const PanenFilter({
    super.key,
    required this.searchController,
    required this.kebuns,
    required this.selectedKebunId,
    required this.selectedDate,
    required this.isScopedToKebun,
    required this.scopedKebunName,
    required this.onKebunChanged,
    required this.onDateChanged,
    required this.onDateCleared,
  });

  final TextEditingController searchController;
  final List<Kebun> kebuns;
  final int? selectedKebunId;
  final DateTime? selectedDate;
  final bool isScopedToKebun;
  final String scopedKebunName;
  final ValueChanged<int?> onKebunChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onDateCleared;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final dateButton = IconButton(
          tooltip: 'Filter tanggal',
          onPressed: () async {
            final value = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: selectedDate ?? DateTime.now(),
            );
            if (value != null && context.mounted) onDateChanged(value);
          },
          style: IconButton.styleFrom(
            backgroundColor: selectedDate == null
                ? Theme.of(context).colorScheme.surfaceContainerLow
                : Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
              color: selectedDate == null
                  ? Theme.of(context).colorScheme.outlineVariant
                  : Theme.of(context).colorScheme.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: Icon(
            Icons.calendar_month_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        );

        final kebunField = DropdownButtonFormField<int>(
          key: ValueKey(selectedKebunId),
          initialValue: selectedKebunId,
          isExpanded: true,
          decoration: _decoration(context, 'Semua kebun', Icons.park_rounded),
          items: [
            const DropdownMenuItem(value: null, child: Text('Semua kebun')),
            if (isScopedToKebun &&
                !kebuns.any((kebun) => kebun.id == selectedKebunId))
              DropdownMenuItem(
                value: selectedKebunId,
                child: Text(scopedKebunName),
              ),
            ...kebuns.map(
              (kebun) =>
                  DropdownMenuItem(value: kebun.id, child: Text(kebun.nama)),
            ),
          ],
          onChanged: isScopedToKebun ? null : onKebunChanged,
        );

        return Column(
          children: [
            TextField(
              controller: searchController,
              decoration:
                  _decoration(
                    context,
                    'Cari kebun...',
                    Icons.search_rounded,
                  ).copyWith(
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: searchController.clear,
                          ),
                  ),
            ),
            const SizedBox(height: 10),
            if (isCompact)
              Row(
                children: [
                  Expanded(child: kebunField),
                  const SizedBox(width: 8),
                  dateButton,
                  if (selectedDate != null)
                    IconButton(
                      onPressed: onDateCleared,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: kebunField),
                  const SizedBox(width: 10),
                  dateButton,
                  if (selectedDate != null)
                    IconButton(
                      onPressed: onDateCleared,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tanggal: ${_formatDate(selectedDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colors.primary, size: 20),
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
