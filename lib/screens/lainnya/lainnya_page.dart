import 'package:flutter/material.dart';
import 'package:nyawit/app.dart';
import 'package:nyawit/data/dummy/settings_dummy.dart';
import 'package:nyawit/screens/lainnya/master_data_page.dart';
import 'package:nyawit/screens/lainnya/tarif_page.dart';
import 'package:nyawit/screens/lainnya/tentang_aplikasi.dart';

class LainnyaPage extends StatelessWidget {
  const LainnyaPage({super.key});

  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color background = Color(0xFFF6F8F6);
  static const Color lightGreen = Color(0xFFE4F3E9);
  static const Color textSecondary = Color(0xFF7B827D);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 18,
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            const _SectionTitle(
              icon: Icons.tune_rounded,
              title: 'Pengaturan & Fitur',
            ),

            const SizedBox(height: 14),

            ...dummySettings.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == dummySettings.length - 1 ? 0 : 14,
                ),
                child: _SettingTile(
                  item: item,
                  onTap: _getOnTap(context, item.title),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  VoidCallback? _getOnTap(BuildContext context, String title) {
    switch (title) {
      case 'Pengaturan aplikasi':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AppSettingsPage()));
        };

      case 'Data pekerja':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PekerjaPage()));
        };

      case 'Data produk':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProdukPage()));
        };

      case 'Tarif':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TarifPage()));
        };

      case 'Data truk':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TrukPage()));
        };

      case 'Lokasi timbang':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LokasiTimbangPage()));
        };

      case 'Tentang aplikasi':
        return () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TentangPage()));
        };

      default:
        return null;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -50,
            child: Container(
              width: 150,
              height: 150,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
          ),

          Positioned(
            left: -55,
            bottom: -75,
            child: Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.035),
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
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Pengaturan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Kelola aplikasi Nyawit',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

              const SizedBox(height: 17),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings_suggest_rounded,
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 17,
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Atur tampilan dan fitur aplikasi '
                      'sesuai kebutuhan.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,

          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),

          child: Icon(icon, size: 19, color: colors.onSecondaryContainer),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.item, this.onTap});

  final SettingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),

        child: Ink(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),

            border: Border.all(color: colors.outlineVariant),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: onTap == null ? colors.outline : colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  static const Color primaryGreen = Color(0xFF176B3A);
  static const Color background = Color(0xFFF6F8F6);

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeScope.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Pengaturan aplikasi',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeader(themeController.isDarkMode),

            const SizedBox(height: 22),

            const _SectionTitle(icon: Icons.palette_rounded, title: 'Tampilan'),

            const SizedBox(height: 14),

            _ThemeCard(
              isDarkMode: themeController.isDarkMode,
              onChanged: themeController.setDarkMode,
            ),

            const SizedBox(height: 16),

            const _InfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tampilan aplikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Sesuaikan tampilan Nyawit dengan '
                  'preferensi Anda.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: colors.outlineVariant),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: colors.onSecondaryContainer,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode gelap',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isDarkMode
                      ? 'Tampilan gelap sedang digunakan'
                      : 'Tampilan terang sedang digunakan',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: isDarkMode,
            onChanged: onChanged,
            activeThumbColor: colors.onPrimary,
            activeTrackColor: colors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(21),

        border: Border.all(color: colors.outlineVariant),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.info_outline_rounded,
              color: colors.onSecondaryContainer,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang pengaturan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Pengaturan tampilan akan diterapkan '
                  'langsung ke seluruh aplikasi.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
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
