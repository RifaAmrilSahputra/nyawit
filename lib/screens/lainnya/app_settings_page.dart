import 'package:flutter/material.dart';
import 'package:nyawit/app.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeController = ThemeScope.of(context);

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Pengaturan aplikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _ThemeCard(
              preference: themeController.preference,
              onChanged: themeController.setPreference,
            ),

            const SizedBox(height: 16),

            const _InfoCard(),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.preference, required this.onChanged});

  final AppThemePreference preference;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema aplikasi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Pilih tampilan yang ingin digunakan.',
          style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        RadioGroup<AppThemePreference>(
          groupValue: preference,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          child: Column(
            children: [
              ...AppThemePreference.values.map(
                (option) => _ThemeOption(
                  option: option,
                  selected: preference == option,
                  label: _themePreferenceLabel(option),
                  description: _themePreferenceDescription(option),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _themePreferenceLabel(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.light => 'Mode terang',
      AppThemePreference.dark => 'Mode gelap',
      AppThemePreference.system => 'Mengikuti perangkat',
    };
  }

  String _themePreferenceDescription(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.light => 'Selalu gunakan tampilan terang',
      AppThemePreference.dark => 'Selalu gunakan tampilan gelap',
      AppThemePreference.system => 'Ikuti pengaturan tema perangkat',
    };
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.option,
    required this.selected,
    required this.label,
    required this.description,
  });

  final AppThemePreference option;
  final bool selected;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final icon = switch (option) {
      AppThemePreference.light => Icons.light_mode_outlined,
      AppThemePreference.dark => Icons.dark_mode_outlined,
      AppThemePreference.system => Icons.brightness_auto_outlined,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected
            ? colors.secondaryContainer.withValues(alpha: 0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: RadioListTile<AppThemePreference>(
        value: option,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        dense: true,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        title: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 28, top: 2),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.3,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Pengaturan tampilan diterapkan langsung ke seluruh aplikasi.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
