import 'package:flutter/material.dart';

class KebunSearchField extends StatelessWidget {
  const KebunSearchField({
    super.key,
    required this.controller,
    required this.query,
  });

  final TextEditingController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Cari nama atau lokasi kebun...',
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF176B3A)),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded, size: 20),
              )
            : null,
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF176B3A), width: 1.5),
        ),
      ),
    );
  }
}
