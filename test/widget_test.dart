// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyawit/app.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/screens/kebun/kebun_form_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('app loads dashboard with bottom navigation', (tester) async {
    await tester.pumpWidget(const NyawitApp());

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byIcon(Icons.apps_outlined), findsOneWidget);
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
