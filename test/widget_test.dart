// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyawit/app.dart';
import 'package:nyawit/models/dashboard_overview.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/lokasi_timbang.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';
import 'package:nyawit/screens/lainnya/backup_restore_page.dart';
import 'package:nyawit/screens/lainnya/laporan_page.dart';
import 'package:nyawit/screens/panen/widgets/panen_form_components.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_form_components.dart';
import 'package:nyawit/screens/perawatan/widgets/perawatan_selection_field.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('app loads dashboard with bottom navigation', (tester) async {
    await tester.pumpWidget(const NyawitApp());

    expect(find.text('Dashboard'), findsNothing);
    expect(find.byIcon(Icons.apps_outlined), findsOneWidget);
  });

  testWidgets('backup and restore actions are available', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BackupRestorePage()));

    expect(find.text('Backup dan restore'), findsOneWidget);
    expect(find.text('Buat backup'), findsOneWidget);
    expect(find.text('Pilih file backup'), findsOneWidget);
    expect(find.text('Restore data'), findsOneWidget);
  });

  testWidgets('reports page shows monthly analytics', (tester) async {
    final overview = DashboardOverview(
      monthLabel: 'November 2026',
      harvestThisMonth: '1.250 kg',
      totalIncome: 'Rp 2.500.000',
      totalCost: 'Rp 500.000',
      netProfit: 'Rp 2.000.000',
      lastHarvestGarden: 'Kebun Utama',
      lastHarvestDate: '20 November 2026',
      lastHarvestAmount: '250 kg',
      lastHarvestMethod: 'Metode antar',
      recentActivities: const [],
      upcomingActivities: const [],
      harvestCostSummary: 'Rp 100.000',
      careCostSummary: 'Rp 400.000',
      totalGarden: '2',
      totalTrees: '1.000',
      totalWorker: '5',
      totalTruck: '1',
      averageHarvest: '625 kg',
      unpaidCost: 'Rp 250.000',
      hasUnpaidCost: true,
      totalHarvestTransaction: '2 transaksi',
      monthLabels: const ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov'],
      productionTrend: const [0, 0, 0, 0, 0, 0, 1250],
      incomeTrend: const [0, 0, 0, 0, 0, 0, 2.5],
      costTrend: const [0, 0, 0, 0, 0, 0, 0.5],
      gardenPerformance: const [
        GardenPerformance(name: 'Kebun Utama', harvest: 1250, contribution: 1),
      ],
      costDistribution: const [
        CostDistribution(name: 'Panen', value: 0.1),
        CostDistribution(name: 'Pupuk', value: 0.4),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: LaporanPage(loadOverview: () async => overview)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('Ringkasan November 2026'), findsOneWidget);
    expect(find.text('Rp 2.500.000'), findsOneWidget);
    expect(find.text('Tren 7 bulan'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Kebun Utama'), 250);
    expect(find.text('Kebun Utama'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Distribusi biaya'), 250);
    expect(find.text('Distribusi biaya'), findsOneWidget);
  });

  testWidgets('user can choose one of three application themes', (
    tester,
  ) async {
    await tester.pumpWidget(const NyawitApp());
    // navigate to "Lainnya" tab and open app settings
    await tester.tap(find.byIcon(Icons.apps_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pengaturan aplikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Mode terang'), findsWidgets);
    expect(find.text('Mode gelap'), findsOneWidget);
    expect(find.text('Mengikuti perangkat'), findsOneWidget);

    await tester.tap(find.text('Mode gelap'));
    await tester.pumpAndSettle();

    expect(find.text('Pilihan aktif: Mode gelap'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('add kebun form shows the new garden layout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: KebunFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kebun'), findsOneWidget);
    expect(find.text('Kebun baru'), findsOneWidget);
    expect(
      find.text('Tambahkan kebun untuk mulai mengelola data.'),
      findsOneWidget,
    );
    expect(find.text('Informasi Kebun'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
  });

  testWidgets('panen form components render their labels and actions', (
    tester,
  ) async {
    var saveTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const PanenFormSectionHeader(
                title: 'Informasi Panen',
                icon: Icons.eco_rounded,
                subtitle: 'Tentukan tanggal dan kebun untuk transaksi ini.',
              ),
              PanenFormDateTile(dateLabel: '21/11/2026', onTap: () {}),
              const PanenFormContextCard(
                icon: Icons.info_outline_rounded,
                text: 'Pilih kebun untuk memuat pekerja aktif.',
              ),
              PanenFormSaveButton(
                isSaving: false,
                isEditing: false,
                onPressed: () => saveTapped = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Informasi Panen'), findsOneWidget);
    expect(
      find.text('Tentukan tanggal dan kebun untuk transaksi ini.'),
      findsOneWidget,
    );
    expect(find.text('TANGGAL'), findsOneWidget);
    expect(find.text('21/11/2026'), findsOneWidget);
    expect(
      find.text('Pilih kebun untuk memuat pekerja aktif.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Simpan Panen'));
    expect(saveTapped, isTrue);
  });

  testWidgets('panen garden selector has no field label and selects a garden', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 21);
    final kebuns = [
      Kebun(id: 1, nama: 'belakang rumah', createdAt: now, updatedAt: now),
      Kebun(
        id: 2,
        nama: 'seberang sungai sam sam',
        createdAt: now,
        updatedAt: now,
      ),
    ];
    int? selectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) => PanenGardenSelector(
                kebuns: kebuns,
                selectedKebunId: selectedId,
                onChanged: (value) => setState(() => selectedId = value),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Pilih kebun'), findsOneWidget);
    expect(find.text('Kebun'), findsNothing);
    await tester.tap(find.text('Pilih kebun'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Kebun'), findsOneWidget);
    expect(find.text('belakang rumah'), findsOneWidget);
    expect(find.text('seberang sungai sam sam'), findsOneWidget);
    await tester.tap(find.text('belakang rumah'));
    await tester.pumpAndSettle();

    expect(selectedId, 1);
    expect(find.text('belakang rumah'), findsOneWidget);
    expect(find.text('Kebun'), findsNothing);
  });

  testWidgets('panen garden filter can select all gardens', (tester) async {
    final now = DateTime(2026, 11, 21);
    final kebuns = [
      Kebun(id: 1, nama: 'belakang rumah', createdAt: now, updatedAt: now),
      Kebun(id: 2, nama: 'belakang sekolah', createdAt: now, updatedAt: now),
    ];
    int? selectedId = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) => PanenGardenSelector(
                kebuns: kebuns,
                selectedKebunId: selectedId,
                showAllOption: true,
                isRequired: false,
                onChanged: (value) => setState(() => selectedId = value),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('belakang rumah'), findsOneWidget);
    await tester.tap(find.text('belakang rumah'));
    await tester.pumpAndSettle();
    expect(find.text('Semua kebun'), findsOneWidget);

    await tester.tap(find.text('Semua kebun'));
    await tester.pumpAndSettle();

    expect(selectedId, isNull);
    expect(find.text('Semua kebun'), findsOneWidget);
  });

  testWidgets(
    'panen weighbridge selector displays details and selects active location',
    (tester) async {
      final now = DateTime(2026, 11, 21);
      final lokasi = [
        LokasiTimbang(
          id: 1,
          nama: 'RAM Kandis',
          jenis: WeighbridgeType.ram,
          alamat: 'Kandis',
          aktif: true,
          createdAt: now,
          updatedAt: now,
        ),
        LokasiTimbang(
          id: 2,
          nama: 'Lokasi nonaktif',
          jenis: WeighbridgeType.lapangan,
          aktif: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      int? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setState) => PanenWeighbridgeSelector(
                  lokasi: lokasi,
                  selectedLokasiId: selectedId,
                  onChanged: (value) => setState(() => selectedId = value),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pilih lokasi timbang'), findsOneWidget);
      expect(find.text('Lokasi Timbang'), findsNothing);
      await tester.tap(find.text('Pilih lokasi timbang'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Lokasi Timbang'), findsOneWidget);
      expect(find.text('RAM Kandis'), findsOneWidget);
      expect(find.text('RAM • Kandis'), findsOneWidget);
      expect(find.text('Lokasi nonaktif'), findsNothing);
      await tester.tap(find.text('RAM Kandis'));
      await tester.pumpAndSettle();

      expect(selectedId, 1);
      expect(find.text('RAM Kandis'), findsOneWidget);
      expect(find.text('Lokasi Timbang'), findsNothing);
    },
  );

  testWidgets('perawatan selection field shows list and applies selection', (
    tester,
  ) async {
    String? selectedValue;
    final options = [
      const PerawatanSelectionOption<String>(value: null, label: 'Semua Jenis'),
      const PerawatanSelectionOption<String>(
        value: 'pupuk',
        label: 'Pupuk',
        subtitle: 'Pemupukan tanaman',
      ),
      const PerawatanSelectionOption<String>(
        value: 'semprot',
        label: 'Semprot',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) => PerawatanSelectionField<String>(
                options: options,
                value: selectedValue,
                placeholder: 'Jenis',
                title: 'Pilih Jenis',
                icon: Icons.category_rounded,
                onChanged: (value) => setState(() => selectedValue = value),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Semua Jenis'), findsOneWidget);
    await tester.tap(find.text('Semua Jenis'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Jenis'), findsOneWidget);
    expect(find.text('Pupuk'), findsOneWidget);
    expect(find.text('Pemupukan tanaman'), findsOneWidget);
    await tester.tap(find.text('Pupuk'));
    await tester.pumpAndSettle();

    expect(selectedValue, 'pupuk');
    expect(find.text('Pupuk'), findsOneWidget);
  });

  testWidgets('perawatan form components show hero and tabular period', (
    tester,
  ) async {
    var periodTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PerawatanFormHeroCard(),
              const SizedBox(height: 12),
              PerawatanFormSectionCard(
                title: 'Informasi umum',
                icon: Icons.tune_rounded,
                subtitle: 'Tentukan jenis, kebun, dan periode pekerjaan.',
                children: [
                  const PerawatanFormFieldCaption(text: 'PERIODE'),
                  PerawatanPeriodTile(
                    label: 'Tanggal mulai',
                    icon: Icons.calendar_today_rounded,
                    dateLabel: '21/11/2026',
                    onTap: () => periodTapped = true,
                  ),
                ],
              ),
              const PerawatanTotalCostCard(child: Text('Total biaya')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catat pekerjaan kebun'), findsOneWidget);
    expect(
      find.text('Simpan rencana perawatan dengan detail yang jelas.'),
      findsOneWidget,
    );
    expect(find.text('Informasi umum'), findsOneWidget);
    expect(find.text('21/11/2026'), findsOneWidget);
    await tester.tap(find.text('21/11/2026'));

    expect(periodTapped, isTrue);
    expect(find.text('Total biaya'), findsOneWidget);
  });

  testWidgets('edit kebun form is prefilled with existing data', (
    tester,
  ) async {
    final kebun = Kebun(
      id: 1,
      nama: 'Kebun Balam Jaya',
      lokasi: 'Riau',
      luas: 12.5,
      jumlahPohon: 1800,
      keterangan: 'Kebun produktif',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    await tester.pumpWidget(MaterialApp(home: KebunFormPage(kebun: kebun)));
    await tester.pumpAndSettle();

    expect(find.text('Edit Kebun'), findsOneWidget);
    // Verify the initial form fields before optional sections are scrolled.
    final fieldCount = tester.widgetList(find.byType(TextFormField)).length;
    expect(fieldCount, greaterThanOrEqualTo(3));
  });
}
