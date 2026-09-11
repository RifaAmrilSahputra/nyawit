import 'package:flutter/material.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  static const String appName = 'Nyawit';
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),

            _buildSectionTitle(
              context,
              icon: Icons.info_outline_rounded,
              title: 'Tentang Nyawit',
            ),
            const SizedBox(height: 12),

            Text(
              'Nyawit adalah aplikasi pengelolaan kebun sawit yang '
              'dirancang untuk membantu mencatat, mengelola, dan '
              'memantau aktivitas kebun secara lebih sederhana dan teratur.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'Fitur Utama',
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              context,
              icon: Icons.landscape_rounded,
              title: 'Manajemen Kebun',
              description:
                  'Kelola data kebun, luas lahan, jumlah pohon, '
                  'pekerja, dan informasi lainnya.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.agriculture_rounded,
              title: 'Pencatatan Panen',
              description:
                  'Catat hasil panen, berat bersih, harga sawit, '
                  'sortir, pekerja, truk, dan lokasi timbang.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.payments_rounded,
              title: 'Pengelolaan Biaya',
              description:
                  'Catat upah panen, ongkos truk, biaya muat, '
                  'serta pembayaran yang telah dilakukan.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.people_alt_rounded,
              title: 'Manajemen Pekerja',
              description:
                  'Kelola data pekerja dan atur pekerja yang '
                  'digunakan pada masing-masing kebun.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.local_shipping_rounded,
              title: 'Manajemen Truk',
              description:
                  'Kelola data truk dan gunakan truk tertentu '
                  'untuk kebutuhan pengangkutan hasil panen.',
            ),

            _buildFeatureCard(
              context,
              icon: Icons.eco_rounded,
              title: 'Perawatan Kebun',
              description:
                  'Mendukung pencatatan aktivitas perawatan kebun '
                  'seperti tunas, penyemprotan, dan pemupukan.',
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              context,
              icon: Icons.cloud_off_rounded,
              title: 'Dibuat untuk Penggunaan Offline',
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.storage_rounded,
              title: 'Data Tersimpan di Perangkat',
              description:
                  'Nyawit menggunakan database lokal SQLite sehingga '
                  'data utama dapat digunakan tanpa koneksi internet.',
            ),

            _buildInfoCard(
              context,
              icon: Icons.speed_rounded,
              title: 'Cepat dan Sederhana',
              description:
                  'Dirancang agar pencatatan aktivitas kebun dapat '
                  'dilakukan dengan cepat tanpa proses yang rumit.',
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              context,
              icon: Icons.settings_suggest_rounded,
              title: 'Informasi Aplikasi',
            ),
            const SizedBox(height: 12),

            _buildAppInfoCard(context),

            const SizedBox(height: 32),

            Center(
              child: Column(
                children: [
                  Icon(Icons.eco_rounded, size: 28, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Nyawit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pengelolaan Kebun Sawit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2026 Nyawit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/iconnyawit.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.eco_rounded,
                  size: 54,
                  color: colorScheme.primary,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pengelolaan Kebun Sawit',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Versi $appVersion',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.apps_rounded,
            label: 'Nama Aplikasi',
            value: appName,
          ),
          _buildDivider(context),
          _buildInfoRow(
            context,
            icon: Icons.numbers_rounded,
            label: 'Versi',
            value: appVersion,
          ),
          _buildDivider(context),
          _buildInfoRow(
            context,
            icon: Icons.phone_android_rounded,
            label: 'Platform',
            value: 'Flutter',
          ),
          _buildDivider(context),
          _buildInfoRow(
            context,
            icon: Icons.storage_rounded,
            label: 'Database',
            value: 'SQLite',
          ),
          _buildDivider(context),
          _buildInfoRow(
            context,
            icon: Icons.wifi_off_rounded,
            label: 'Mode',
            value: 'Offline',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
