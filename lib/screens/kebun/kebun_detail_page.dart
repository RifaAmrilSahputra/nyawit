import 'package:flutter/material.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';

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
    final status = (kebun.keterangan?.isNotEmpty ?? false) ? 'Aktif' : 'Siap';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Kebun',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _editKebun(context),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              icon: const Icon(Icons.edit_rounded, size: 20),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _KebunDetailHeader(kebun: kebun, status: status),
          const SizedBox(height: 22),
          _DetailSection(
            icon: Icons.info_outline_rounded,
            title: 'Informasi Kebun',
            children: [
              _InfoTile(
                icon: Icons.park_rounded,
                label: 'Nama kebun',
                value: kebun.nama,
              ),
              _InfoTile(
                icon: Icons.location_on_rounded,
                label: 'Lokasi',
                value: kebun.lokasi ?? 'Belum diisi',
              ),
              _InfoTile(
                icon: Icons.straighten_rounded,
                label: 'Luas',
                value: kebun.luas == null ? 'Belum diisi' : '${kebun.luas} Ha',
              ),
              _InfoTile(
                icon: Icons.forest_rounded,
                label: 'Jumlah pohon',
                value: kebun.jumlahPohon == null
                    ? 'Belum diisi'
                    : '${kebun.jumlahPohon} pohon',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            icon: Icons.notes_rounded,
            title: 'Catatan',
            children: [
              _InfoTile(
                icon: Icons.notes_rounded,
                label: 'Keterangan',
                value: kebun.keterangan ?? 'Belum ada keterangan',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            icon: Icons.history_rounded,
            title: 'Informasi Data',
            children: [
              _InfoTile(
                icon: Icons.calendar_today_rounded,
                label: 'Dibuat',
                value: _formatDate(kebun.createdAt),
              ),
              _InfoTile(
                icon: Icons.update_rounded,
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

class _KebunDetailHeader extends StatelessWidget {
  const _KebunDetailHeader({required this.kebun, required this.status});

  final Kebun kebun;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF176B3A),
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
            child: const Icon(
              Icons.forest_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kebun.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        kebun.lokasi ?? 'Lokasi belum diisi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _KebunStatusBadge(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KebunStatusBadge extends StatelessWidget {
  const _KebunStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE5F5EA) : const Color(0xFFFFF3DD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF26964D)
                  : const Color(0xFFD58A00),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? const Color(0xFF227E43)
                  : const Color(0xFFAA6D00),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F3E9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: const Color(0xFF176B3A)),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 0),
          Icon(icon, size: 18, color: const Color(0xFF176B3A)),
          const SizedBox(width: 11),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7B827D)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
