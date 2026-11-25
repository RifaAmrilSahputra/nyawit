import 'package:intl/intl.dart';
import 'package:nyawit/core/database/database_helper.dart';
import 'package:nyawit/models/activity.dart';
import 'package:nyawit/models/dashboard_overview.dart';
import 'package:nyawit/models/kebun.dart';
import 'package:nyawit/models/kegiatan_perawatan.dart';
import 'package:nyawit/models/panen.dart';
import 'package:nyawit/models/tarif_perawatan.dart';

class DashboardRepository {
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  Future<DashboardOverview> loadOverview({DateTime? now}) async {
    final date = now ?? DateTime.now();
    final db = await DatabaseHelper.instance.database;
    final results = await Future.wait<List<Map<String, Object?>>>([
      db.query('kebun', orderBy: 'nama ASC'),
      db.rawQuery('''
          SELECT p.*, k.nama AS nama_kebun
          FROM panen p
          LEFT JOIN kebun k ON k.id = p.kebun_id
          ORDER BY p.tanggal DESC
        '''),
      db.rawQuery('SELECT COUNT(*) AS jumlah FROM pekerja'),
      db.rawQuery('SELECT COUNT(*) AS jumlah FROM truk'),
      db.rawQuery('''
          SELECT k.*, COALESCE(SUM(p.jumlah), 0) AS total_dibayar,
            b.nama AS nama_kebun
          FROM kegiatan_perawatan k
          LEFT JOIN pembayaran_perawatan p
            ON p.kegiatan_perawatan_id = k.id
          LEFT JOIN kebun b ON b.id = k.kebun_id
          GROUP BY k.id
          ORDER BY k.tanggal_mulai DESC
        '''),
      db.rawQuery('''
          SELECT b.jenis, b.total_biaya,
            COALESCE(SUM(p.jumlah), 0) AS total_dibayar,
            h.tanggal
          FROM biaya_panen b
          JOIN panen h ON h.id = b.panen_id
          LEFT JOIN pembayaran_biaya_panen p ON p.biaya_panen_id = b.id
          GROUP BY b.id
        '''),
    ]);

    final gardens = results[0].map(Kebun.fromMap).toList();
    final gardenNames = {
      for (final garden in gardens)
        if (garden.id != null) garden.id!: garden.nama,
    };
    final harvests = results[1].map(Panen.fromMap).toList();
    final careItems = results[4].map(KegiatanPerawatan.fromMap).toList();
    final careGardenNames = {
      for (final row in results[4])
        row['id'] as int: row['nama_kebun'] as String? ?? 'Kebun dihapus',
    };

    final monthStart = DateTime(date.year, date.month);
    final today = DateTime(date.year, date.month, date.day);
    final periodStarts = List.generate(
      7,
      (index) => DateTime(date.year, date.month - 6 + index),
    );
    final periodKeys = {
      for (var index = 0; index < periodStarts.length; index++)
        _monthKey(periodStarts[index]): index,
    };
    final productionByMonth = List<double>.filled(7, 0);
    final incomeByMonth = List<double>.filled(7, 0);
    final costByMonth = List<double>.filled(7, 0);
    final harvestByGarden = <int, double>{};

    var monthProduction = 0.0;
    var monthIncome = 0.0;
    var monthHarvestCount = 0;
    Panen? lastHarvest;

    for (final harvest in harvests) {
      if (harvest.tanggal.isAfter(date)) continue;
      lastHarvest ??= harvest;

      final key = _monthKey(harvest.tanggal);
      final index = periodKeys[key];
      final income = harvest.beratBersih * harvest.hargaSawit;
      if (index != null) {
        productionByMonth[index] += harvest.beratBersih;
        incomeByMonth[index] += income;
      }

      if (_isSameMonth(harvest.tanggal, monthStart)) {
        monthProduction += harvest.beratBersih;
        monthIncome += income;
        monthHarvestCount++;
        harvestByGarden.update(
          harvest.kebunId,
          (value) => value + harvest.beratBersih,
          ifAbsent: () => harvest.beratBersih,
        );
      }
    }

    var monthHarvestCost = 0.0;
    var allUnpaidCost = 0.0;
    for (final row in results[5]) {
      final total = (row['total_biaya'] as num).toDouble();
      final paid = (row['total_dibayar'] as num).toDouble();
      allUnpaidCost += (total - paid).clamp(0, double.infinity);
      final costDate = DateTime.parse(row['tanggal'] as String);
      final index = periodKeys[_monthKey(costDate)];
      if (index != null) costByMonth[index] += total;
      if (_isSameMonth(costDate, monthStart)) monthHarvestCost += total;
    }

    var monthCareCost = 0.0;
    final careCostByType = <String, double>{};
    for (final item in careItems) {
      allUnpaidCost += (item.totalBiaya - item.totalDibayar).clamp(
        0,
        double.infinity,
      );
      final index = periodKeys[_monthKey(item.tanggalMulai)];
      if (index != null) costByMonth[index] += item.totalBiaya;

      if (_isSameMonth(item.tanggalMulai, monthStart)) {
        monthCareCost += item.totalBiaya;
        careCostByType.update(
          item.jenis.label,
          (value) => value + item.totalBiaya,
          ifAbsent: () => item.totalBiaya,
        );
      }
    }

    final totalCost = monthHarvestCost + monthCareCost;
    final gardenPerformance =
        harvestByGarden.entries
            .map(
              (entry) => GardenPerformance(
                name: gardenNames[entry.key] ?? 'Kebun dihapus',
                harvest: entry.value,
                contribution: monthProduction == 0
                    ? 0
                    : entry.value / monthProduction,
              ),
            )
            .toList()
          ..sort((a, b) => b.harvest.compareTo(a.harvest));

    final costDistribution = <CostDistribution>[
      if (monthHarvestCost > 0)
        CostDistribution(name: 'Panen', value: monthHarvestCost / 1000000),
      for (final entry in careCostByType.entries)
        if (entry.value > 0)
          CostDistribution(name: entry.key, value: entry.value / 1000000),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final recentActivities = <({DateTime date, ActivityItem item})>[];
    final upcomingActivities = <({DateTime date, ActivityItem item})>[];

    for (final harvest in harvests) {
      if (harvest.tanggal.isAfter(date)) continue;
      recentActivities.add((
        date: harvest.tanggal,
        item: ActivityItem(
          id: 'panen-${harvest.id}',
          type: ActivityType.panen,
          title: 'Panen',
          gardenName: gardenNames[harvest.kebunId] ?? 'Kebun dihapus',
          date: _formatDate(harvest.tanggal),
          amount: '${_formatNumber(harvest.beratBersih)} kg',
          cost: '-',
          status: harvest.shippingMethod == ShippingMethod.antar
              ? 'Antar'
              : 'Di lapangan',
          paymentStatus: '-',
        ),
      ));
    }

    for (final item in careItems) {
      final startDate = DateTime(
        item.tanggalMulai.year,
        item.tanggalMulai.month,
        item.tanggalMulai.day,
      );
      if (item.statusKegiatan == StatusKegiatan.dibatalkan) continue;

      final activity = ActivityItem(
        id: 'perawatan-${item.id}',
        type: _activityType(item.jenis),
        title: item.namaKegiatan?.trim().isNotEmpty == true
            ? item.namaKegiatan!.trim()
            : item.jenis.label,
        gardenName: careGardenNames[item.id] ?? 'Kebun dihapus',
        date: _formatDate(item.tanggalMulai),
        amount: '-',
        cost: _formatCurrency(item.totalBiaya),
        status: item.statusKegiatan.label,
        paymentStatus: _paymentStatus(item.totalBiaya, item.totalDibayar),
      );

      final isUpcoming =
          startDate.isAfter(today) ||
          (startDate.isAtSameMomentAs(today) &&
              item.statusKegiatan == StatusKegiatan.rencana);
      if (isUpcoming) {
        upcomingActivities.add((date: item.tanggalMulai, item: activity));
      } else {
        recentActivities.add((date: item.tanggalMulai, item: activity));
      }
    }

    recentActivities.sort((a, b) => b.date.compareTo(a.date));
    upcomingActivities.sort((a, b) => a.date.compareTo(b.date));
    final lastHarvestGarden = lastHarvest == null
        ? null
        : gardenNames[lastHarvest.kebunId] ?? 'Kebun dihapus';

    return DashboardOverview(
      monthLabel: '${_months[date.month - 1]} ${date.year}',
      harvestThisMonth: '${_formatNumber(monthProduction)} kg',
      totalIncome: _formatCurrency(monthIncome),
      totalCost: _formatCurrency(totalCost),
      netProfit: _formatCurrency(monthIncome - totalCost),
      lastHarvestGarden: lastHarvestGarden,
      lastHarvestDate: lastHarvest == null
          ? null
          : _formatDate(lastHarvest.tanggal),
      lastHarvestAmount: lastHarvest == null
          ? null
          : '${_formatNumber(lastHarvest.beratBersih)} kg',
      lastHarvestMethod: lastHarvest == null
          ? null
          : lastHarvest.shippingMethod == ShippingMethod.antar
          ? 'Metode antar'
          : 'Diangkut dari lapangan',
      recentActivities: recentActivities
          .take(5)
          .map((entry) => entry.item)
          .toList(),
      upcomingActivities: upcomingActivities
          .take(5)
          .map((entry) => entry.item)
          .toList(),
      harvestCostSummary: _formatCurrency(monthHarvestCost),
      careCostSummary: _formatCurrency(monthCareCost),
      totalGarden: _formatNumber(gardens.length),
      totalTrees: _formatNumber(
        gardens.fold<int>(0, (sum, garden) => sum + (garden.jumlahPohon ?? 0)),
      ),
      totalWorker: _formatNumber(_count(results[2])),
      totalTruck: _formatNumber(_count(results[3])),
      averageHarvest: monthHarvestCount == 0
          ? '0 kg'
          : '${_formatNumber(monthProduction / monthHarvestCount)} kg',
      unpaidCost: _formatCurrency(allUnpaidCost),
      hasUnpaidCost: allUnpaidCost > 0,
      totalHarvestTransaction: '$monthHarvestCount transaksi',
      monthLabels: periodStarts
          .map((period) => _shortMonths[period.month - 1])
          .toList(),
      productionTrend: productionByMonth,
      incomeTrend: incomeByMonth.map((value) => value / 1000000).toList(),
      costTrend: costByMonth.map((value) => value / 1000000).toList(),
      gardenPerformance: gardenPerformance.take(5).toList(),
      costDistribution: costDistribution,
    );
  }

  static int _monthKey(DateTime date) => date.year * 12 + date.month;

  static bool _isSameMonth(DateTime date, DateTime month) =>
      date.year == month.year && date.month == month.month;

  static int _count(List<Map<String, Object?>> rows) =>
      (rows.first['jumlah'] as num?)?.toInt() ?? 0;

  static String _formatCurrency(num value) => 'Rp ${_formatNumber(value)}';

  static String _formatNumber(num value) =>
      NumberFormat('#,##0', 'en_US').format(value.round()).replaceAll(',', '.');

  static String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String _paymentStatus(double total, double paid) {
    if (paid == 0) return 'Belum dibayar';
    if (paid < total) return 'Kurang bayar';
    if (paid == total) return 'Lunas';
    return 'Lebih bayar';
  }

  static ActivityType _activityType(JenisPerawatan type) => switch (type) {
    JenisPerawatan.pupuk => ActivityType.pupuk,
    JenisPerawatan.tunas => ActivityType.tunas,
    JenisPerawatan.semprot => ActivityType.semprot,
    JenisPerawatan.lainnya => ActivityType.lainnya,
  };
}
