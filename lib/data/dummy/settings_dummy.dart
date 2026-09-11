class SettingItem {
  const SettingItem({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final String icon;
  final String subtitle;
}

const List<SettingItem> dummySettings = [
  SettingItem(
    title: 'Pengaturan aplikasi',
    icon: '⚙️',
    subtitle: 'Tema, preferensi umum',
  ),
  SettingItem(
    title: 'Tarif',
    icon: '💰',
    subtitle: 'Harga panen dan biaya operasional',
  ),
  SettingItem(
    title: 'Data pekerja',
    icon: '👷',
    subtitle: 'Daftar pekerja kebun',
  ),
  SettingItem(
    title: 'Data produk',
    icon: '📦',
    subtitle: 'Produk pupuk, semprot, dan bahan perawatan',
  ),
  SettingItem(
    title: 'Data truk',
    icon: '🚚',
    subtitle: 'Armada dan jadwal pengiriman',
  ),
  SettingItem(
    title: 'Lokasi timbang',
    icon: '📍',
    subtitle: 'Pos timbang dan titik distribusi',
  ),
  SettingItem(
    title: 'Backup data',
    icon: '💾',
    subtitle: 'Cadangan data aplikasi',
  ),
  SettingItem(
    title: 'Restore data',
    icon: '📥',
    subtitle: 'Pulihkan data backup',
  ),
  SettingItem(
    title: 'Laporan',
    icon: '📊',
    subtitle: 'Rekap bulanan dan analisis',
  ),
  SettingItem(
    title: 'Tentang aplikasi',
    icon: 'ℹ️',
    subtitle: 'Versi dan informasi umum',
  ),
];
