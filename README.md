<div align="center">

# 🌴 Nyawit

### Aplikasi pencatatan dan pengelolaan perkebunan kelapa sawit

Kelola data kebun, aktivitas panen, perawatan, biaya, dan laporan dalam satu
aplikasi Flutter dengan penyimpanan SQLite lokal.

</div>

---

## Daftar isi

- [Tentang aplikasi](#tentang-aplikasi)
- [Fitur](#fitur)
- [Alur penggunaan](#alur-penggunaan)
- [Teknologi](#teknologi)
- [Memulai](#memulai)
- [Pengujian](#pengujian)
- [Struktur proyek](#struktur-proyek)
- [Penyimpanan dan backup](#penyimpanan-dan-backup)

## Tentang aplikasi

Nyawit membantu mencatat operasional kebun sawit, dari data dasar kebun hingga
transaksi panen dan kegiatan perawatan. Informasi disimpan di database lokal
perangkat, sehingga aplikasi tidak memerlukan akun atau backend untuk alur
pencatatan yang tersedia.

Aplikasi menyediakan tampilan dashboard, pengelolaan data master, laporan,
pilihan tema, serta fitur backup dan restore data.

## Fitur

| Modul | Kemampuan |
| --- | --- |
| **Dashboard** | Ringkasan metrik kebun dan aktivitas, tren, serta informasi operasional. |
| **Kebun** | Tambah, lihat, ubah, dan cari kebun; kelola penugasan pekerja dan truk. |
| **Panen** | Catat transaksi panen, berat, harga, sortir, metode pengiriman, lokasi timbang, pekerja, pengangkutan, biaya, dan pembayaran. |
| **Perawatan** | Catat kegiatan dan periode perawatan, produk, pekerja, biaya, status kegiatan, serta pembayaran. |
| **Data master** | Kelola pekerja, produk, truk, lokasi timbang, dan tarif. |
| **Laporan** | Tinjau ringkasan dan analitik kegiatan perkebunan. |
| **Backup & restore** | Ekspor database ke file JSON, tinjau isi backup, lalu pulihkan data setelah konfirmasi. |
| **Tema** | Pilih tema terang, gelap, atau mengikuti pengaturan perangkat. |

### Detail pencatatan

- Data panen mencakup kebun, tanggal, berat bersih, harga sawit, sortir, metode
  pengiriman, dan lokasi timbang.
- Pekerja dapat dikaitkan dengan kebun, transaksi panen, maupun kegiatan
  perawatan.
- Truk dapat ditugaskan ke kebun dan dicatat pada pengangkutan hasil panen.
- Biaya panen dan perawatan mendukung pencatatan pembayaran.
- Data produk digunakan pada aktivitas perawatan dan dapat memiliki tarif.

## Alur penggunaan

1. **Siapkan data master** — masukkan pekerja, produk, truk, lokasi timbang,
   serta tarif yang digunakan.
2. **Daftarkan kebun** — lengkapi informasi kebun dan, bila diperlukan,
   tetapkan pekerja serta truk.
3. **Catat operasional** — buat transaksi panen atau kegiatan perawatan,
   kemudian hubungkan dengan data kebun dan data master terkait.
4. **Tinjau hasil** — gunakan dashboard dan laporan untuk melihat ringkasan
   kegiatan dan biaya.
5. **Amankan data** — buat backup secara berkala dan simpan file di lokasi yang
   aman.

> **Perhatian:** proses restore mengganti seluruh data lokal aplikasi dengan
> data dari file backup yang dipilih. Pastikan memilih file yang benar sebelum
> mengonfirmasi pemulihan.

## Teknologi

- **Flutter** untuk antarmuka aplikasi lintas platform.
- **Dart** dengan batas versi SDK `^3.9.2` (lihat [`pubspec.yaml`](pubspec.yaml)).
- **SQLite** melalui `sqflite` sebagai penyimpanan lokal.
- **SQLite FFI** melalui `sqflite_common_ffi` untuk penggunaan desktop dan
  pengujian database lokal.
- **Intl** untuk pemformatan tanggal dan angka.
- **File Picker** untuk memilih file backup dan menentukan lokasi penyimpanan.

## Memulai

### Prasyarat

- Flutter SDK yang menyertakan Dart `3.9.2` atau lebih baru dalam rentang SDK
  proyek.
- Android/iOS device atau emulator, atau target desktop/web yang sudah
  dikonfigurasi untuk Flutter.
- Untuk pengujian SQLite FFI di Linux, library native SQLite tersedia di sistem.

Periksa instalasi Flutter dan daftar target yang terdeteksi:

```bash
flutter doctor
flutter devices
```

### Instalasi dan menjalankan

Jalankan dari root repository:

```bash
flutter pub get
flutter run
```

Untuk memilih target secara eksplisit, gunakan ID dari `flutter devices`:

```bash
flutter run -d <device-id>
```

Runner proyek tersedia untuk Android, iOS, Linux, macOS, Windows, dan web.
Kebutuhan SDK platform, simulator, atau konfigurasi signing mengikuti target
yang dipilih.

## Pengujian

Jalankan analisis statis dan seluruh pengujian:

```bash
flutter analyze
flutter test
```

Pengujian dapat dijalankan per file:

```bash
flutter test test/widget_test.dart
flutter test test/biaya_panen_test.dart
flutter test test/db_repository_test.dart
flutter test test/database_backup_service_test.dart
```

Tes repository dan backup menggunakan SQLite FFI. Pada Linux, bila tes
melaporkan `Failed to load dynamic library 'libsqlite3.so'`, pasang library
SQLite pengembangan, misalnya:

```bash
sudo apt install libsqlite3-dev
```

Kemudian jalankan kembali `flutter test`.

## Struktur proyek

```text
lib/
├── app.dart                    # Tema aplikasi dan root MaterialApp
├── main.dart                   # Entry point dan inisialisasi platform
├── core/
│   ├── database/               # SQLite, migrasi, dan backup/restore
│   └── theme/                  # Tema terang dan gelap
├── models/                     # Model dan pemetaan data
├── navigation/                 # Shell dan navigasi utama
├── providers/                  # Provider/controller data
├── repositories/               # Operasi baca/tulis database
└── screens/
    ├── dashboard/
    ├── kebun/
    ├── panen/
    ├── perawatan/
    ├── kegiatan/
    └── lainnya/                # Laporan, master data, pengaturan, backup
test/                           # Widget, model, repository, dan backup tests
```

Database lokal bernama `sawit_management.db`. Skema dan migrasi dikelola oleh
[`DatabaseHelper`](lib/core/database/database_helper.dart); operasi backup dan
restore berada di `lib/core/database/`.

## Penyimpanan dan backup

- Data operasional disimpan secara lokal pada perangkat yang menjalankan
  aplikasi.
- Backup diekspor sebagai file JSON dan dapat dipindahkan atau disimpan oleh
  pengguna.
- Restore memvalidasi dan menampilkan ringkasan isi file sebelum mengganti
  database saat ini.
- Simpan salinan backup di lokasi aman di luar perangkat. Ketersediaan backup
  bergantung pada file yang disimpan pengguna.

---

<div align="center">

Dikembangkan oleh **Amril Nadapdap** dengan Flutter untuk membantu pencatatan
operasional perkebunan.

</div>
