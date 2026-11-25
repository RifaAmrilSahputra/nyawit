import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';
import 'package:nyawit/screens/kebun/widgets/kebun_detail_widgets.dart';

class KebunDetailPage extends StatelessWidget {
  const KebunDetailPage({super.key, required this.kebun});

  final Kebun kebun;

  Future<void> _editKebun(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => KebunFormPage(kebun: kebun)),
    );

    if (changed == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

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
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Kembali',
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: colors.onSurface,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Detail Kebun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _editKebun(context),
              tooltip: 'Edit kebun',
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHighest,
                minimumSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.edit_rounded, size: 19),
            ),
          ),
        ],
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          KebunDetailHero(kebun: kebun),

          const SizedBox(height: 26),

          const KebunDetailSectionTitle(
            icon: Icons.info_outline_rounded,
            title: 'Informasi kebun',
          ),

          const SizedBox(height: 10),

          KebunDetailInfoGroup(
            children: [
              KebunDetailInfoTile(
                icon: Icons.park_outlined,
                label: 'Nama kebun',
                value: kebun.nama,
              ),
              KebunDetailInfoTile(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: kebun.lokasi ?? 'Belum diisi',
              ),
              KebunDetailInfoTile(
                icon: Icons.straighten_outlined,
                label: 'Luas',
                value: kebun.luas == null ? 'Belum diisi' : '${kebun.luas} Ha',
              ),
              KebunDetailInfoTile(
                icon: Icons.forest_outlined,
                label: 'Jumlah pohon',
                value: kebun.jumlahPohon == null
                    ? 'Belum diisi'
                    : '${kebun.jumlahPohon} pohon',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 22),

          const KebunDetailSectionTitle(
            icon: Icons.notes_outlined,
            title: 'Catatan',
          ),

          const SizedBox(height: 10),

          KebunDetailInfoGroup(
            children: [
              KebunDetailInfoTile(
                icon: Icons.notes_outlined,
                label: 'Keterangan',
                value: kebun.keterangan ?? 'Belum ada keterangan',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 22),

          const KebunDetailSectionTitle(
            icon: Icons.history_rounded,
            title: 'Informasi data',
          ),

          const SizedBox(height: 10),

          KebunDetailInfoGroup(
            children: [
              KebunDetailInfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Dibuat',
                value: _formatDate(kebun.createdAt),
              ),
              KebunDetailInfoTile(
                icon: Icons.update_outlined,
                label: 'Diperbarui',
                value: _formatDate(kebun.updatedAt),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
