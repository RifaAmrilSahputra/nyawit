import 'package:flutter/material.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  static const String appName = 'Nyawit';
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Tentang Aplikasi',
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            _buildHero(context),

            const SizedBox(height: 34),

            _buildIntro(context),

            const SizedBox(height: 34),

            _buildSectionTitle(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'Yang bisa dilakukan Nyawit',
            ),

            const SizedBox(height: 14),

            _buildFeatureList(context),

            const SizedBox(height: 34),

            _buildOfflineSection(context),

            const SizedBox(height: 34),

            _buildSectionTitle(
              context,
              icon: Icons.info_outline_rounded,
              title: 'Informasi aplikasi',
            ),

            const SizedBox(height: 14),

            _buildAppInfo(context),

            const SizedBox(height: 40),

            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/iconnyawit.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.eco_rounded, size: 48, color: colors.primary);
            },
          ),
        ),

        const SizedBox(height: 18),

        Text(
          appName,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Pengelolaan Kebun Sawit',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Versi $appVersion',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang Nyawit',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Nyawit adalah aplikasi pengelolaan kebun sawit yang '
          'dirancang untuk membantu mencatat, mengelola, dan '
          'memantau aktivitas kebun secara lebih sederhana dan teratur.',
          style: TextStyle(
            fontSize: 13,
            height: 1.65,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Column(
      children: [
        _FeatureItem(
          icon: Icons.landscape_rounded,
          title: 'Manajemen Kebun',
          description:
              'Kelola data kebun, luas lahan, jumlah pohon, pekerja, '
              'dan informasi lainnya.',
        ),

        _FeatureItem(
          icon: Icons.agriculture_rounded,
          title: 'Pencatatan Panen',
          description:
              'Catat hasil panen, berat bersih, harga sawit, sortir, '
              'pekerja, truk, dan lokasi timbang.',
        ),

        _FeatureItem(
          icon: Icons.payments_rounded,
          title: 'Pengelolaan Biaya',
          description:
              'Catat upah panen, ongkos truk, biaya muat, '
              'serta pembayaran yang telah dilakukan.',
        ),

        _FeatureItem(
          icon: Icons.people_alt_rounded,
          title: 'Manajemen Pekerja',
          description:
              'Kelola data pekerja dan atur pekerja yang '
              'digunakan pada masing-masing kebun.',
        ),

        _FeatureItem(
          icon: Icons.local_shipping_rounded,
          title: 'Manajemen Truk',
          description:
              'Kelola data truk dan gunakan truk tertentu '
              'untuk kebutuhan pengangkutan hasil panen.',
        ),

        _FeatureItem(
          icon: Icons.eco_rounded,
          title: 'Perawatan Kebun',
          description:
              'Mendukung pencatatan aktivitas perawatan kebun '
              'seperti tunas, penyemprotan, dan pemupukan.',
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildOfflineSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 20,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Dibuat untuk penggunaan offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _OfflineItem(
            icon: Icons.storage_rounded,
            title: 'Data tersimpan di perangkat',
            description:
                'Nyawit menggunakan database lokal SQLite sehingga '
                'data utama dapat digunakan tanpa koneksi internet.',
          ),

          const SizedBox(height: 14),

          _OfflineItem(
            icon: Icons.speed_rounded,
            title: 'Cepat dan sederhana',
            description:
                'Dirancang agar pencatatan aktivitas kebun dapat '
                'dilakukan dengan cepat tanpa proses yang rumit.',
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.apps_rounded,
            label: 'Nama aplikasi',
            value: appName,
          ),

          _InfoDivider(),

          _InfoRow(
            icon: Icons.numbers_rounded,
            label: 'Versi',
            value: appVersion,
          ),

          _InfoDivider(),

          _InfoRow(
            icon: Icons.phone_android_rounded,
            label: 'Platform',
            value: 'Flutter',
          ),

          _InfoDivider(),

          _InfoRow(
            icon: Icons.storage_rounded,
            label: 'Database',
            value: 'SQLite',
          ),

          _InfoDivider(),

          _InfoRow(
            icon: Icons.wifi_off_rounded,
            label: 'Mode',
            value: 'Offline',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(Icons.eco_rounded, size: 24, color: colors.primary),

        const SizedBox(height: 8),

        Text(
          'Nyawit',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'Pengelolaan Kebun Sawit',
          style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 10),

        Text(
          '© 2026 Nyawit',
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
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
                child: Icon(icon, size: 19, color: colors.onSecondaryContainer),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10.8,
                        height: 1.45,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
    );
  }
}

class _OfflineItem extends StatelessWidget {
  const _OfflineItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: colors.primary),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                description,
                style: TextStyle(
                  fontSize: 10.8,
                  height: 1.45,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      indent: 44,
      endIndent: 15,
      thickness: 0.6,
      color: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
