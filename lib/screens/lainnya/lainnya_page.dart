import 'package:flutter/material.dart';
import 'package:nyawit/data/dummy/settings_dummy.dart';
import 'package:nyawit/screens/lainnya/app_settings_page.dart';
import 'package:nyawit/screens/lainnya/master_data_page.dart';
import 'package:nyawit/screens/lainnya/tarif_page.dart';
import 'package:nyawit/screens/lainnya/tentang_aplikasi.dart';

class LainnyaPage extends StatelessWidget {
  const LainnyaPage({super.key});

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
        titleSpacing: 20,
        toolbarHeight: 0,
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _SettingsList(
              items: dummySettings,
              onTap: (title) => _getOnTap(context, title),
            ),
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
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.items, required this.onTap});

  final List<SettingItem> items;
  final VoidCallback? Function(String title) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return _SettingTile(
            item: item,
            onTap: onTap(item.title),
            showDivider: index < items.length - 1,
          );
        }),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.item,
    required this.onTap,
    required this.showDivider,
  });

  final SettingItem item;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Center(
                      child: Text(
                        item.icon,
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.6,
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
